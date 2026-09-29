require 'spec_helper'

# The Rack 3 SPEC requires response header names to be lowercase: "Header keys
# must not contain uppercase ASCII characters (A-Z)".
#
# These examples look at the raw response triple on purpose. Rack::Test, and
# Rack::Response itself, normalize header names on read, so going through
# `last_response` would hide both a capitalized name and a duplicated one.
describe Rack::Robustness, 'header names' do

  def headers_of(app)
    _, headers, _ = app.to_app.call(Rack::MockRequest.env_for("/"))
    headers
  end

  def failing_app(&bl)
    Rack::Builder.new do
      use Rack::Robustness, &bl
      run lambda{|env| raise ArgumentError, "an argument error" }
    end
  end

  context 'with the default configuration' do
    it 'emits a lowercase content-type' do
      expect(headers_of(failing_app).keys).to eq(['content-type'])
    end
  end

  context 'on the happy path' do
    let(:app) {
      Rack::Builder.new do
        use Rack::Robustness
        run lambda{|env| [200, {'Content-Type' => 'text/plain'}, ['happy']] }
      end
    }

    it 'emits lowercase names, whatever the application uses' do
      expect(headers_of(app)).to eq({'content-type' => 'text/plain'})
    end
  end

  context 'when the DSL is given capitalized names' do
    it 'emits them lowercased, without duplicating content-type' do
      app = failing_app do |g|
        g.headers 'Content-Type' => 'text/test', 'X-Foo' => 'Bar'
      end
      expect(headers_of(app)).to eq({
        'content-type' => 'text/test',
        'x-foo'        => 'Bar'
      })
    end
  end

  # Before 2.0.0 the default headers were keyed 'Content-Type', so configuring
  # 'content-type' added a *second* entry rather than overriding. Since the
  # clauses are applied with `||=`, the default won and the configured value
  # was silently dropped -- and lowercase is precisely what Rack 3 users write.
  context 'when the DSL overrides a default header in another case' do
    ['content-type', 'Content-Type', 'CONTENT-TYPE'].each do |name|
      it "honours the value given as #{name}" do
        app = failing_app{|g| g.headers name => 'application/json' }
        expect(headers_of(app)).to eq({'content-type' => 'application/json'})
      end
    end
  end

  context 'when a headers block returns capitalized names' do
    it 'emits them lowercased' do
      app = failing_app do |g|
        g.headers{|ex| { 'Content-Type' => 'text/test', 'X-Foo' => 'Bar' } }
      end
      expect(headers_of(app)).to eq({
        'content-type' => 'text/test',
        'x-foo'        => 'Bar'
      })
    end
  end

  context 'when a rescue clause returns capitalized names' do
    it 'emits them lowercased' do
      app = failing_app do |g|
        g.rescue(ArgumentError){|ex| [400, {'X-Foo' => 'Bar'}, ['nope']] }
      end
      expect(headers_of(app).keys.sort).to eq(['content-type', 'x-foo'])
    end
  end

  context 'in last resort' do
    it 'emits a lowercase content-type' do
      app = Rack::Builder.new do
        use(Rack::Robustness){|g| g.response{|ex| NoSuchResponseClass.new } }
        run lambda{|env| raise ArgumentError, "an argument error" }
      end
      expect(headers_of(app).keys).to eq(['content-type'])
    end
  end

end
