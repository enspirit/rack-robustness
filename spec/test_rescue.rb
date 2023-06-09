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
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq("argument-error")
  end

  it 'correctly support a non-block shortcut' do
    get '/security-error'
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq("security-error")
  end

  it 'is has a `on` alias' do
    get '/type-error'
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq("type-error")
  end

end
