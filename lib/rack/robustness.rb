module Rack
  class Robustness

    VERSION = "1.0.0".freeze

    NIL_HANDLER = lambda{|ex| nil }

    def initialize(app)
      @app       = app
      @handlers  = {}
      @status    = 500
      @headers   = {'Content-Type' => "text/plain"}
      @body      = ["Sorry, a fatal error occured."]
      @catch_all = true
      yield self if block_given?
      on(Object){|ex| [@status, {}, @body]} if @catch_all
      @headers.freeze
      @body.freeze
    end

    ##
    # Configuration

    def no_catch_all
      @catch_all = false
    end

    def on(ex_class, &bl)
      @handlers[ex_class] = bl || NIL_HANDLER
    end

    def status(s=nil, &bl)
      @status = s || bl
    end

    def headers(h=nil, &bl)
      if h.nil?
        @headers = bl
      else
        @headers.merge!(h)
      end
    end

    def content_type(ct=nil, &bl)
      headers('Content-Type' => ct || bl)
    end

    def body(b=nil, &bl)
      @body = b.nil? ? bl : (String===b ? [ b ] : b)
    end

    ##
    # Rack's call

    def call(env)
      @app.call(env)
    rescue => ex
      handler = error_handler(ex.class)
      raise unless handler
      handle_response(handler, ex)
    end

  private

    def handle_response(response, ex)
      case response
      when NilClass then handle_response([@status,  {},       @body], ex)
      when Fixnum   then handle_response([response, {},       @body], ex)
      when String   then handle_response([@status,  {},       response], ex)
      when Hash     then handle_response([@status,  response, @body], ex)
      when Proc     then handle_response(response.call(ex), ex)
      else
        status, headers, body = response.map{|x| handle_value(x, ex) }
        [ status,
          handle_value(@headers, ex).merge(headers),
          body ]
      end
    end

    def handle_value(value, ex)
      case value
      when Proc then value.call(ex)
      when Hash then value.each_with_object({}){|(k,v),h| h[k] = handle_value(v, ex)}
      else
        value
      end
    end

    def error_handler(ex_class)
      return nil if ex_class.nil?
      @handlers.fetch(ex_class){ error_handler(ex_class.superclass) }
    end

 end # class Robustness
end # module Rack
