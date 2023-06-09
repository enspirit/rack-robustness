require 'spec_helper'
describe Rack::Robustness do
  include Rack::Test::Methods

  shared_examples_for 'A transparent middleware for happy paths' do

    it 'let happy responses unchanged' do
      get '/happy'
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('text/plain')
      expect(last_response.body).to eq('happy')
    end
  end

  context 'with the default configuration' do
    let(:app){
      mock_app
    }

    it_should_behave_like 'A transparent middleware for happy paths'

    it 'set a status 500 with a standard error message by default' do
      get '/argument-error'
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq("text/plain")
      expect(last_response.body).to eq("Sorry, a fatal error occured.")
    end

    it 'catches all exceptions by default' do
      get '/security-error'
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq("text/plain")
      expect(last_response.body).to eq("Sorry, a fatal error occured.")
    end
  end

  context 'with a status, content_type and body constants' do
    let(:app){
      mock_app do |g|
        g.status 501
        g.content_type "text/test"
        g.body "An error occured"
      end
    }

    it_should_behave_like 'A transparent middleware for happy paths'

    it 'set the specified status and body on errors' do
      get '/argument-error'
      expect(last_response.status).to eq(501)
      expect(last_response.content_type).to eq("text/test")
      expect(last_response.body).to eq("An error occured")
    end
  end

  context 'with headers' do
    let(:app){
      mock_app do |g|
        g.headers 'Content-Type' => 'text/test',
                  'Foo' => 'Bar'
      end
    }

    it_should_behave_like 'A transparent middleware for happy paths'

    it 'set the specified headers on error' do
      get '/argument-error'
      last_response.headers['Foo'].should eq('Bar')
      expect(last_response.content_type).to eq("text/test")
    end
  end

  context 'with a dynamic status, content_type and body' do
    let(:app){
      mock_app do |g|
        g.status      {|ex| ArgumentError===ex ? 400 : 500}
        g.content_type{|ex| ArgumentError===ex ? "text/arg" : 'text/other'}
        g.body        {|ex| ex.message }
      end
    }

    it_should_behave_like 'A transparent middleware for happy paths'

    it 'correctly sets the status, content_type and body on ArgumentError' do
      get '/argument-error'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('text/arg')
      expect(last_response.body).to eq('an argument error')
    end

    it 'correctly sets the status, content_type and body on TypeError' do
      get '/type-error'
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq('text/other')
      expect(last_response.body).to eq('a type error')
    end
  end

  context 'with dynamic headers I' do
    let(:app){
      mock_app do |g|
        g.headers{|ex|
          {'Content-Type' => ArgumentError===ex ? "text/arg" : 'text/other' }
        }
      end
    }

    it_should_behave_like 'A transparent middleware for happy paths'

    it 'correctly sets the specified headers on an ArgumentError' do
      get '/argument-error'
      expect(last_response.content_type).to eq("text/arg")
    end

    it 'correctly sets the specified headers on a TypeError' do
      get '/type-error'
      expect(last_response.content_type).to eq("text/other")
    end
  end

  context 'with dynamic headers II' do
    let(:app){
      mock_app do |g|
        g.headers 'Content-Type' => lambda{|ex| ArgumentError===ex ? "text/arg" : 'text/other'},
                  'Foo' => 'Bar'
      end
    }

    it_should_behave_like 'A transparent middleware for happy paths'

    it 'correctly sets the specified headers on an ArgumentError' do
      get '/argument-error'
      last_response.headers['Foo'].should eq('Bar')
      expect(last_response.content_type).to eq("text/arg")
    end

    it 'correctly sets the specified headers on a TypeError' do
      get '/type-error'
      last_response.headers['Foo'].should eq('Bar')
      expect(last_response.content_type).to eq("text/other")
    end
  end

  context 'when responding to specific errors with a full response' do
    let(:app){
      mock_app do |g|
        g.headers 'Foo' => 'Bar', 'Content-Type' => 'default/one'
        g.on(ArgumentError){|ex| [401, {'Content-Type' => 'text/arg'}, [ ex.message ] ] }
        g.on(TypeError){|ex| [402, {}, [ ex.message ] ] }
      end
    }

    after do
      # if merges the default headers in any way
      last_response.headers['Foo'].should eq('Bar')
    end

    it 'uses the response on ArgumentError' do
      get '/argument-error'
      expect(last_response.status).to eq(401)
      expect(last_response.content_type).to eq('text/arg')
      expect(last_response.body).to eq("an argument error")
    end

    it 'uses the response on TypeError' do
      get '/type-error'
      expect(last_response.status).to eq(402)
      expect(last_response.content_type).to eq('default/one')
      expect(last_response.body).to eq("a type error")
    end
  end

  context 'when responding to specific errors with a single status' do
    let(:app){
      mock_app do |g|
        g.on(ArgumentError){|ex| 401 }
      end
    }

    it 'uses the status and fallback to defaults for the rest' do
      get '/argument-error'
      expect(last_response.status).to eq(401)
      expect(last_response.content_type).to eq('text/plain')
      expect(last_response.body).to eq("Sorry, a fatal error occured.")
    end
  end

  context 'when responding to specific errors with a single body' do
    let(:app){
      mock_app do |g|
        g.on(ArgumentError){|ex| ex.message }
      end
    }

    it 'uses it as body and fallback to defaults for the rest' do
      get '/argument-error'
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to eq('text/plain')
      expect(last_response.body).to eq("an argument error")
    end
  end

  context 'when configured with no_catch_all' do
    let(:app){
      mock_app do |g|
        g.no_catch_all
        g.on(ArgumentError){|ex| 401 }
      end
    }

    it 'matches known errors' do
      get '/argument-error'
      expect(last_response.status).to eq(401)
    end

    it 'raises on unknown error' do
      lambda{
        get '/type-error'
      }.should raise_error(TypeError)
    end
  end

  context 'when responding to specific errors without body' do
    let(:app){
      mock_app do |g|
        g.no_catch_all
        g.status(401)
        g.on(ArgumentError)
      end
    }

    it 'matches known errors' do
      get '/argument-error'
      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("Sorry, a fatal error occured.")
    end

    it 'raises on unknown error' do
      lambda{
        get '/type-error'
      }.should raise_error(TypeError)
    end
  end

end
