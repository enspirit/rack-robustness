## 1.2.0

* Modernize with test matrix on ruby 2.7, 3.1, and 3.2

* Fix usage of Fixnum to be compatible with Ruby 3.x

## 1.1.0 / 2013-04-16

* Fixed catching of non standard errors (e.g. SecurityError)

* Global headers are now correctly overrided by specific per-exception headers

* Renamed `#on` as `#rescue` for better capturing semantics of `on` blocks (now an alias).

* Added last resort exception handling if an error occurs during exception handling itself.
  In `no_catch_all` mode, the exception is simply reraised; otherwise a default 500 error
  is returned with a safe message.

* Added a shortcut form for `#rescue` clauses allowing values directly, e.g.,

        use Rack::Robustness do |g|
          g.rescue(SecurityError, 403)
        end

* Added suppport for ensure clause(s), always called after `rescue` blocks

* Rack's `env` is now available in all error handling blocks, e.g.,

        use Rack::Robustness do |g|
          g.status{|ex| ... env ... }
          g.body  {|ex| ... env ... }
          g.rescue(SecurityError){|ex| ... env ... }
          g.ensure{|ex| ... env ... }
        end

* Similarly, Rack::Robustness now internally uses instances of Rack::Request and Rack::Response;
  `request` and `response` are available in all blocks. The specific Response
  object to use can be built using the `response` DSL method, e.g.,

        use Rack::Robustness do |g|
          g.response{|ex| MyOwnRackResponse.new }
        end

* Rack::Robustness may now be subclassed as an alternative to inline `use`, e.g.

        class Shield < Rack::Robustness
          self.body  {|ex| ... }
          self.rescue(SecurityError){|ex| ... }
          ...
        end

        # in Rack-based configuration
        use Shield

## 1.0.0 / 2013-02-26

* Enhancements

  * Birthday!
