require 'spec_helper'
describe "Rack::Robustness subclasses" do
  include Rack::Test::Methods

  class Shield < Rack::Robustness
    self.body{|ex| ex.message }
    self.rescue(ArgumentError){|ex| 400 }
  end

  let(:app){
    mock_app(Shield)
  }

  it 'works as expected' do
    get '/argument-error'
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq("an argument error")
  end

end
