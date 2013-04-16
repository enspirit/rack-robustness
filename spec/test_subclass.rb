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
    last_response.status.should eq(400)
    last_response.body.should eq("an argument error")
  end

end