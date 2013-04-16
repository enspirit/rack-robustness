module Rack
  class Robustness

    VERSION = "1.0.0".freeze

    def self.new(app, &bl)
      return super(app) if bl.nil? and not(Robustness==self)
      Class.new(self).install(&bl).new(app)
    end

    ##
    # Configuration
    module DSL

      NIL_HANDLER = lambda{|ex| nil }

      def inherited(x)
        x.reset
      end

      def reset
        @rescue_clauses  = {}
        @ensure_clauses  = []
        @status_clause   = 500
        @headers_clause  = {'Content-Type' => "text/plain"}
        @body_clause     = ["Sorry, a fatal error occured."]
        @catch_all       = true
      end
      attr_reader :rescue_clauses, :ensure_clauses, :status_clause,
                  :headers_clause, :body_clause, :catch_all

      def install
        yield self if block_given?
        on(Object){|ex| 
          [status_clause, {}, body_clause]
        } if @catch_all
        @headers_clause.freeze
        @body_clause.freeze
        @rescue_clauses.freeze
        @ensure_clauses.freeze
        self
      end

      def no_catch_all
        @catch_all = false
      end

      def rescue(ex_class, &bl)
        @rescue_clauses[ex_class] = bl || NIL_HANDLER
      end
      alias :on :rescue

      def ensure(bypass_on_success = false, &bl)
        @ensure_clauses << [bypass_on_success, bl]
      end

      def status(s=nil, &bl)
        @status_clause = s || bl
      end

      def headers(h=nil, &bl)
        if h.nil?
          @headers_clause = bl
        else
          @headers_clause.merge!(h)
        end
      end

      def content_type(ct=nil, &bl)
        headers('Content-Type' => ct || bl)
      end

      def body(b=nil, &bl)
        @body_clause = b.nil? ? bl : (String===b ? [ b ] : b)
      end

    end # module DSL
    extend DSL

  public

    def initialize(app)
      @app = app
    end

    ##
    # Rack's call

    def call(env)
      dup.call!(env)
    end

  protected

    def call!(env)
      @env, @request = env, Rack::Request.new(env)
      handle_happy @app.call(env)
      @response.finish
    rescue => ex
      handle_rescue ex
      @response.finish
    ensure
      handle_ensure ex
    end

  private

    attr_reader :env, :request, :response

    [ :rescue_clauses,
      :ensure_clauses,
      :status_clause,
      :headers_clause,
      :body_clause,
      :catch_all ].each do |m|
      define_method(m){|*args, &bl|
        self.class.send(m, *args, &bl)
      }
    end

    def handle_happy(triple)
      s, h, b = triple
      @response = Response.new(b, s, h)
    end

    def handle_rescue(ex)
      @response = Rack::Response.new
      if rescue_clause = find_rescue_clause(ex.class)
        handle_error(ex, rescue_clause)
      else
        raise(ex)
      end
    end

    def handle_ensure(ex)
      ensure_clauses.each{|(bypass,ensurer)|
        instance_exec(ex, &ensurer) if ex or not(bypass)
      }
    end

    def handle_error(ex, rescue_clause)
      case rescue_clause
      when NilClass then handle_error(ex, [status_clause,  {},           body_clause])
      when Fixnum   then handle_error(ex, [rescue_clause,  {},           body_clause])
      when String   then handle_error(ex, [status_clause,  {},           rescue_clause])
      when Hash     then handle_error(ex, [status_clause, rescue_clause, body_clause])
      when Proc     then handle_error(ex, handle_value(ex, rescue_clause))
      else
        status, headers, body = rescue_clause
        handle_status(ex, status)
        handle_headers(ex, headers_clause)
        handle_headers(ex, headers)
        handle_body(ex, body)
      end
    end

    def handle_status(ex, status)
      @response.status = handle_value(ex, status)
    end

    def handle_headers(ex, headers)
      handle_value(ex, headers).each_pair do |key,value|
        @response[key] = handle_value(ex, value)
      end
    end

    def handle_body(ex, body)
      body = handle_value(ex, body)
      @response.body = body.is_a?(String) ? [ body ] : body
    end

    def handle_value(ex, value)
      value.is_a?(Proc) ? instance_exec(ex, &value) : value
    end

    def find_rescue_clause(ex_class)
      return nil if ex_class.nil?
      rescue_clauses.fetch(ex_class){ find_rescue_clause(ex_class.superclass) }
    end

 end # class Robustness
end # module Rack
