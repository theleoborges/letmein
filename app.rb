require 'sinatra'
require 'digest/sha1'
require 'json'
require 'data_mapper'
require './user'


DataMapper::Logger.new($stdout, :debug)
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/letmein.db")
end
configure :production do
  DataMapper.setup(:default, ENV['SHARED_DATABASE_URL'])
end
DataMapper.finalize

use Rack::Auth::Basic do |username, password|
  username == 'letmein' && password == 'pXrE4efbslOkCHtu'
end


get '/:api_key/authenticate' do
  user = User.first(:api_key => params[:api_key])
  return 500 if user.nil?
  erb :login, :locals => {api_key: user.api_key, return_to: params[:return_to]}
end

post '/authenticate' do
  user = User.first(:api_key => params[:api_key])
  return 500 if user.nil?
  if params[:username].nil? || params[:username].empty?
    redirect "#{params[:return_to]}?user=#{params[:username]}&status=error"
  else
    redirect "#{params[:return_to]}?user=#{params[:username]}&status=ok"
  end
end

post '/heroku/resources' do
  api_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)
  user = User.create(api_key: api_key, created_at: Time.now)
  result = { :id => user.api_key, 
    :config => { "LETMEIN_URL" => url("/#{api_key}") } 
  }
  result.to_json
end

delete '/heroku/resources/:id' do
  user = User.first(:api_key => params[:id])
  user.destroy if user
  "ok"
end