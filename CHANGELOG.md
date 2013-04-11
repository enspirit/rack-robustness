# 1.1.0 / 2013-04-11

* Renamed `#on` as `#rescue` for better capturing semantics of `on` blocks (now an alias)
* Added suppport for ensure clause(s), called after `rescue` blocks on every error
* Rack's `env` is now available in all error handling blocks, e.g.,

        use Rack::Robustness do |g|
          g.rescue{|ex| ... env ... }
          g.ensure{|ex| ... env ... }
          g.body  {|ex| ... env ... }
          g.status{|ex| ... env ... }
        end

# 1.0.0 / 2013-02-26

* Enhancements

  * Birthday!
