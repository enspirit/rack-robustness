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
        @rescue_clauses   = {}
        @ensure_clauses   = []
        @status_clause    = 500
        @headers_clause   = {'Content-Type' => "text/plain"}
        @body_clause      = ["Sorry, a fatal error occured."]
        @response_builder = lambda{|ex| ::Rack::Response.new }
        @catch_all        = true
      end
      attr_reader :rescue_clauses, :ensure_clauses, :status_clause,
                  :headers_clause, :body_clause, :catch_all, :response_builder

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

      def response(&bl)
        @response_builder = bl
      end

      def rescue(ex_class, handler = nil, &bl)
        @rescue_clauses[ex_class] = handler || bl || NIL_HANDLER
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
    rescue => ex
       catch_all ? last_resort(ex) : raise(ex)
    end

  protected

    def call!(env)
      @env, @request = env, Rack::Request.new(env)
      triple = @app.call(env)
      handle_happy(triple)
    rescue Exception => ex
      handle_rescue(ex)
    ensure
      handle_ensure(ex)
    end

  private

    attr_reader :env, :request, :response

    [ :response_builder,
      :rescue_clauses,
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
      @response.finish
    end

    def handle_rescue(ex)
      begin
        # build a response instance
        @response = instance_exec(ex, &response_builder)

        # populate it if a rescue clause can be found
        if rescue_clause = find_rescue_clause(ex.class)
          handle_error(ex, rescue_clause)
          return @response.finish
        end

        # no_catch_all mode, let reraise it later
      rescue Exception => ex2
        return catch_all ? last_resort(ex2) : raise(ex2)
      end

      # we are in no_catch_all mode, reraise
      raise(ex)
    end

    def handle_ensure(ex)
      @response ||= begin
        status, headers, body = last_resort(ex)
        ::Rack::Response.new(body, status, headers)
      end
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
        handle_headers(ex, headers)
        handle_headers(ex, headers_clause)
        handle_body(ex, body)
      end
    end

    def handle_status(ex, status)
      @response.status = handle_value(ex, status)
    end

    def handle_headers(ex, headers)
      handle_value(ex, headers).each_pair do |key,value|
        @response[key] ||= handle_value(ex, value)
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

    def last_resort(ex)
      [ 500,
        {'Content-Type' => 'text/plain'},
        [ 'An internal error occured, sorry for the disagreement.' ] ]
    end

 end # class Robustness
end # module Rack
