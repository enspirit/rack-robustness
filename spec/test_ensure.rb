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
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq("error")
    expect($seen_true).to eq([ArgumentError])
    expect($seen_false).to eq([ArgumentError])
    expect($seen_none).to eq([ArgumentError])
  end

  it 'should not be called when explicit bypass on happy paths' do
    get '/happy'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("happy")
    expect($seen_true).to be_nil
    expect($seen_false).to eq([NilClass])
    expect($seen_none).to eq([NilClass])
  end

end
