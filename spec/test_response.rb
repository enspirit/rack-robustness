require 'spec_helper'
describe Rack::Robustness, 'response' do
  include Rack::Test::Methods

  class MyFooResponse < Rack::Response

    def initialize(*args)
      super
      self['Content-Type'] = "application/json"
    end

    def each
      yield("response text")
    end

  end

  let(:app){
    mock_app do |g|
      g.status 400
      g.response{|ex| MyFooResponse.new }
    end
  }

  it 'correctly sets the status' do
    get '/argument-error'
    last_response.status.should eq(400)
  end

  it 'correctly sets the body' do
    get '/argument-error'
    last_response.body.should eq("response text")
  end

  it 'correctly sets the content type' do
    get '/argument-error'
    last_response.content_type.should eq("application/json")
  end

end
