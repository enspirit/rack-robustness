require 'spec_helper'
describe Rack::Robustness, 'ensure' do
  include Rack::Test::Methods

  let(:app){
    mock_app do |g|
      g.ensure(true) {|ex| $seen_true  = [ex.class] }
      g.ensure(false){|ex| $seen_false = [ex.class] }
      g.ensure       {|ex| $seen_none  = [ex.class] }
      g.status 400
      g.on(ArgumentError){|ex| "error" }
    end
  }

  before do
    $seen_true = $seen_false = $seen_none = nil
  end

  it 'should be called in all cases when an error occurs' do
    get '/argument-error'
    last_response.status.should eq(400)
    last_response.body.should eq("error")
    $seen_true.should eq([ArgumentError])
    $seen_false.should eq([ArgumentError])
    $seen_none.should eq([ArgumentError])
  end

  it 'should not be called when explicit bypass on happy paths' do
    get '/happy'
    last_response.status.should eq(200)
    last_response.body.should eq("happy")
    $seen_true.should be_nil
    $seen_false.should eq([NilClass])
    $seen_none.should eq([NilClass])
  end

end
