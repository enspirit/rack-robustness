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
      expect($seen_ex).to be_a(ArgumentError)
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
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq("text/plain")
      expect(last_response.body).to eq("An internal error occured, sorry for the disagreement.")
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
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq("text/plain")
      expect(last_response.body).to eq("An internal error occured, sorry for the disagreement.")
    end
  end

  context 'when the response block fails and the ensure block uses the response object' do
    let(:app){
      mock_app do |g|
        g.response{|ex| NoSuchResponseClass.new }
        g.ensure{|ex| $seen_response = response }
      end
    }

    before do
      $seen_response = nil
    end

    it 'sets a default response object for the ensure clause' do
      get '/argument-error'
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq("text/plain")
      expect(last_response.body).to eq("An internal error occured, sorry for the disagreement.")
      expect($seen_response).to_not be_nil
    end
  end

end
