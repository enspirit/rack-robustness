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
          [cls.status_clause, {}, cls.body_clause]
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
      @env = env
      @app.call(env)
    rescue => ex
      raise unless handler = error_handler(ex.class)
      handle_response(handler, ex)
    ensure
      cls.ensure_clauses.each{|(bypass,ensurer)|
        instance_exec(ex, &ensurer) if ex or not(bypass)
      }
    end

  private

    attr_reader :env

    def cls
      self.class
    end

    def handle_response(response, ex)
      case response
      when NilClass then handle_response([cls.status_clause,  {},       cls.body_clause], ex)
      when Fixnum   then handle_response([response,           {},       cls.body_clause], ex)
      when String   then handle_response([cls.status_clause,  {},       response], ex)
      when Hash     then handle_response([cls.status_clause,  response, cls.body_clause], ex)
      when Proc     then handle_response(instance_exec(ex, &response), ex)
      else
        s, h, b = response.map{|x| handle_value(x, ex) }
        [ s, handle_value(cls.headers_clause, ex).merge(h), b ]
      end
    end

    def handle_value(value, ex)
      case value
      when Proc then instance_exec(ex, &value)
      when Hash then value.each_with_object({}){|(k,v),h| h[k] = handle_value(v, ex) }
      else
        value
      end
    end

    def error_handler(ex_class)
      return nil if ex_class.nil?
      cls.rescue_clauses.fetch(ex_class){ error_handler(ex_class.superclass) }
    end

 end # class Robustness
end # module Rack
