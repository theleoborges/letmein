require 'sinatra'

post '/auth' do
  "Hello #{params[:username]}!"
end