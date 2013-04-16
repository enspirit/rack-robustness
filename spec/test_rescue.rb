require 'spec_helper'
describe Rack::Robustness, 'rescue' do
  include Rack::Test::Methods

  let(:app){
    mock_app do |g|
      g.status 400
      g.rescue(ArgumentError){|ex| 'argument-error' }
      g.rescue(SecurityError, 'security-error')
      g.on(TypeError)        {|ex| 'type-error'     }
    end
  }

  it 'correctly rescues specified errors' do
    get '/argument-error'
    last_response.status.should eq(400)
    last_response.body.should eq("argument-error")
  end

  it 'correctly support a non-block shortcut' do
    get '/security-error'
    last_response.status.should eq(400)
    last_response.body.should eq("security-error")
  end

  it 'is has a `on` alias' do
    get '/type-error'
    last_response.status.should eq(400)
    last_response.body.should eq("type-error")
  end

end
