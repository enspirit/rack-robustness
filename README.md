# Rack::Robustness

Rack::Robustness is a middleware that ensures the robustness of your web stack. From zero configuration to shared configuration to specific behavior for specific errors...

[![Build Status](https://secure.travis-ci.org/blambeau/rack-robustness.png)](http://travis-ci.org/blambeau/rack-robustness)
[![Dependency Status](https://gemnasium.com/blambeau/rack-robustness.png)](https://gemnasium.com/blambeau/rack-robustness)

## Links

https://github.com/blambeau/rack-robustness

## Why? Example.

In my opinion, Sinatra's error handling is sometimes a bit limited for real-case needs. So I came up with something a but Rack-ish, that allows scenarios as the following one:

```ruby
class App < Sinatra::Base

  ##
  # Catch everything but hide root causes, for security reasons, for instance.
  #
  # This handler should never be fired unless the application has a bug...
  #
  use Rack::Robustness do |g|
    g.status 500
    g.content_type 'text/plain'
    g.body 'A fatal error occured.'
  end

  ##
  # Some middleware here for logging, content lenght of whatever.
  #
  # Those middleware might fail, even if unlikely.
  #
  use ...
  use ...

  ##
  # Catch some exceptions that denote client errors by convention in our app.
  #
  # Those exceptions are considered safe, so the message is sent to the user.
  #
  use Rack::Robustness do |g|
    g.no_catch_all                 # do not catch all errors

    g.status 400                   # default status to 400, client error
    g.content_type 'text/plain'    # a default content-type, maybe
    g.body{|ex| ex.message }       # by default, send the message

    # catch ArgumentError, it denotes a coercion error in our app
    g.on(ArgumentError)

    # we use SecurityError for handling forbidden accesses.
    # The default status is 403 here
    g.on(SecurityError){|ex| 403 }
  end

  get '/some/route/:id' do |id|
    id = Integer(id) # will raise a ArgumentError if not an integer

    ...
  end

  get '/private' do |id|
    raise SecurityError unless logged?

    ...
  end

end
```

## Without configuration

```ruby
##
# Catches all errors.
#
# Respond with
#   status:  500,
#   headers: {'Content-Type' => 'text/plain'}
#   body:    [ "Sorry, an error occured." ]
#
use Rack::Robustness
```

## Specifying static status, headers and/or body

```ruby
##
# Catches all errors.
#
# Respond as specified.
#
use Rack::Robustness do |g|
  g.status 400
  g.headers 'Content-Type' => 'text/html'
  g.content_type 'text/html'               # shortcut over headers
  g.body "<p>an error occured</p>"
end
```

## Specifying dynamic status, content_type and/or body

```ruby
##
# Catches all errors.
#
# Respond as specified.
#
use Rack::Robustness do |g|
  g.status{|ex| ArgumentError===ex ? 400 : 500 }

  # global dynamic headers
  g.headers{|ex| {'Content-Type' => 'text/plain', ...} }

  # local dynamic and/or static headers
  g.headers 'Content-Type' => lambda{|ex| ... },
            'Foo' => 'Bar'

  # dynamic content type
  g.content_type{|ex| ...}

  # dynamic body (String allowed here)
  g.body{|ex| ex.message }
end
```

## Specific behavior for specific errors

```ruby
##
# Catches all errors using defaults as above
#
# Respond to specific errors as specified by 'on' clauses.
#
use Rack::Robustness do |g|
  g.status 500                    # this is the default behavior, as above
  g.content_type 'text/plain'     # ...

  # Override status on TypeError and descendants
  g.on(TypeError){|ex| 400 }

  # Override body on ArgumentError and descendants
  g.on(ArgumentError){|ex| ex.message }

  # Override everything on SecurityError and descendants
  # Default headers will be merged with returned ones so content-type will be
  # "text/plain" unless specified below
  g.on(SecurityError){|ex|
    [ 403, { ... }, [ "Forbidden, sorry" ] ]
  }
end
```

## Don't catch all!

```ruby
##
# Catches only errors specified in 'on' clauses, using defaults as above
#
# Re-raise unrecognized errors
#
use Rack::Robustness do |g|
  g.no_catch_all

  g.on(TypeError){|ex| 400 }
  ...
end
```
