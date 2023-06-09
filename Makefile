tests.unit:
	bundle exec rake test

tests: tests.unit

package:
	bundle exec rake package

gem.push:
	ls pkg/rack-robustness-*.gem | xargs gem push
