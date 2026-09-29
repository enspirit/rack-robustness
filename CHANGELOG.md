## 2.0.0 / 2026-09-29

The Rack 3 release.

* BREAKING: response header names are now emitted in lowercase, as required
  by the Rack 3 SPEC ("Header keys must not contain uppercase ASCII
  characters"). Names given to the DSL are normalized, so `'content-type'`,
  `'Content-Type'` and `'CONTENT-TYPE'` all name the same header:

      use Rack::Robustness do |g|
        g.headers 'X-Error' => 'boom'   # emitted as x-error
      end

  Under Rack 3 this was mostly already the case, since Rack::Response
  normalizes what it is given. The path that was genuinely non-compliant was
  the last resort response, returned as a raw triple when error handling
  itself fails. Header names are case-insensitive on the wire, so the change
  is invisible to clients; it is only visible to code asserting on the raw
  Rack triple, or to a middleware reading headers case-sensitively.

* BREAKING: fixed the default headers silently winning over a configured one
  written in another case. `g.headers('content-type' => 'application/json')`
  used to be ignored, the `'Content-Type' => 'text/plain'` default taking
  precedence, because the two keys did not collide and clauses are applied
  with `||=`. Lowercase being what Rack 3 users naturally write, this was
  easy to hit and silent. Applications that worked around it by writing
  `'Content-Type'` are unaffected.

* BREAKING: Ruby >= 3.2 is now required, and the test matrix covers 3.2, 3.3
  and 3.4. Ruby 2.7 and 3.1 have both reached end of life.

* BREAKING: Rack 3 is now required. Rack 2 reached its last feature release
  in 2022 and nothing here is worth keeping a compatibility branch for. Stay
  on the 1.x line if you are still on Rack 2.

* `rack` is now a proper runtime dependency, `>= 3.0, < 4.0`. It was only a
  development dependency before, even though the middleware has always used
  `Rack::Request` and `Rack::Response`. `lib/rack/robustness.rb` requires it
  explicitly rather than assuming the host application already did.

* The version moved to `rack/robustness/version.rb`, so that the gemspec can
  read it without loading Rack, which would activate a Rack version before
  Bundler gets to constrain it.

* Fixed `rake` being entirely broken: `tasks/gem.rake` eval'd the gemspec
  without a filename, so `__FILE__` resolved to `(eval)` and the `$LOAD_PATH`
  entry it computes pointed nowhere.

* Development dependencies were stale to the point of being wrong (rspec
  ~> 2.12 while the suite is rspec 3, rake ~> 10, rack ~> 1.5). They now
  match what is actually used, rack-test included, moving from 0.6 to 2.x.

* The gemspec dropped its Noe boilerplate, along with `Manifest.txt` and the
  dangling `rack-robustness.noespec` entry it carried. `.travis.yml` is
  removed too, CI having moved to GitHub Actions.

## 1.2.0 / 2023-06-09

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
