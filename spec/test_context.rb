require 'spec_helper'
describe Rack::Robustness, 'the context in which blocks execute' do
  include Rack::Test::Methods

  let(:app){
    mock_app do |g|
      g.response{|ex|
        raise "Invalid context" unless env && request
        Rack::Response.new
      }
      g.body{|ex|
        raise "Invalid context" unless env && request && response
        if response.status == 400
          "argument-error"
        else
          "security-error"
        end
      }
      g.rescue(ArgumentError){|ex|
        raise "Invalid context" unless env && request && response
        400
      }
      g.rescue(SecurityError){|ex|
        raise "Invalid context" unless env && request && response
        403
      }
      g.ensure{|ex|
        raise "Invalid context" unless env && request && response
        $seen_ex = ex
      }
    end
  }

  it 'should let `env`, `request` and `response` be available in all blocks' do
    get '/argument-error'
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq('argument-error')
  end

  it 'executes the ensure block as well' do
    get '/argument-error'
    expect($seen_ex).to be_a(ArgumentError)
  end

end
