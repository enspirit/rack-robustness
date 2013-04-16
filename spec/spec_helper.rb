$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack'
require 'rack/robustness'
require 'rack/test'

module SpecHelpers

  def mock_app(clazz = Rack::Robustness, &bl)
    Rack::Builder.new do
      use clazz, &bl
      map '/happy' do
        run lambda{|env| [200, {'Content-Type' => 'text/plain'}, ['happy']]}
      end
      map "/argument-error" do
        run lambda{|env| raise ArgumentError, "an argument error" }
      end
      map "/type-error" do
        run lambda{|env| raise TypeError, "a type error" }
      end
      map "/security-error" do
        run lambda{|env| raise SecurityError, "a security error" }
      end
    end
  end

  def app
    mock_app{}
  end

end

RSpec.configure do |c|
  c.include SpecHelpers
end
