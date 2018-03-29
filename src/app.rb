require 'bundler/setup'
require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    "Hello World to the Dania's family"
  end

  get '/ping' do
    'pong'
  end
end
