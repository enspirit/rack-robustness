require 'spec_helper'
describe Rack::Robustness, 'last resort' do
  include Rack::Test::Methods

  before do
    $seen_ex = nil
  end

  context 'when the response cannot be built and no catch all' do
    let(:app){
      mock_app do |g|
        g.no_catch_all
        g.response{|ex| NoSuchResponseClass.new }
        g.ensure(true){|ex| $seen_ex = ex }
      end
    }

    it 'reraises the internal error' do
      lambda{
        get '/argument-error'
      }.should raise_error(NameError, /NoSuchResponseClass/)
    end

    it 'passes into the ensure block with the original error' do
      lambda{
        get '/argument-error'
      }.should raise_error(NameError, /NoSuchResponseClass/)
      $seen_ex.should be_a(ArgumentError)
    end
  end

  context 'when the response cannot be built and catch all' do
    let(:app){
      mock_app do |g|
        g.response{|ex| NoSuchResponseClass.new }
      end
    }

    it 'falls back to last resort response' do
      get '/argument-error'
      last_response.status.should eq(500)
      last_response.content_type.should eq("text/plain")
      last_response.body.should eq("An internal error occured, sorry for the disagreement.")
    end
  end

  context 'when an ensure block raises an error and no catch all' do
    let(:app){
      mock_app do |g|
        g.no_catch_all
        g.ensure{|ex| NoSuchResponseClass.new }
      end
    }

    it 'reraises the internal error' do
      lambda{
        get '/argument-error'
      }.should raise_error(NameError, /NoSuchResponseClass/)
    end
  end

  context 'when an ensure block raises an error and catch all' do
    let(:app){
      mock_app do |g|
        g.ensure{|ex| NoSuchResponseClass.new }
      end
    }

    it 'reraises the internal error' do
      get '/argument-error'
      last_response.status.should eq(500)
      last_response.content_type.should eq("text/plain")
      last_response.body.should eq("An internal error occured, sorry for the disagreement.")
    end
  end

end
