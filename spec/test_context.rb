require 'spec_helper'
describe Rack::Robustness, 'the context in which block execute' do
  include Rack::Test::Methods

  let(:app){
    mock_app do |g|
      g.status{|ex|
        raise "Missing env" unless env
        403
      }
      g.rescue(ArgumentError){|ex|
        raise "Missing env" unless env
        env['CONTENT_TYPE']
      }
      g.ensure{|ex|
        raise "Missing env" unless env
        $seen_ex = ex
      }
    end
  }

  it 'should let `env` be available in all blocks' do
    header('Content-Type', 'text/plain')
    get '/argument-error'
    last_response.status.should eq(403)
    last_response.body.should eq('text/plain')
    $seen_ex.should be_a(ArgumentError)
  end

end
