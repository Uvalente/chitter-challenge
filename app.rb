require 'sinatra/base'
require 'sinatra/flash'
require_relative 'database_connection_setup'
require './lib/user'
require './lib/peep'

class Chitter < Sinatra::Base
  enable :sessions, :method_override
  register Sinatra::Flash

  get '/' do
    redirect '/peeps'
  end

  get '/peeps' do
    @user = User.find(id: session[:user_id])
    @peeps = Peep.all
    erb :'peeps/index'
  end

  post '/peeps' do
    Peep.create(user_id: session[:user_id], content: params[:content])
    redirect '/peeps'
  end

  get '/users/new' do
    redirect '/peeps' if User.find(id: session[:user_id])
    erb :'users/new'
  end

  get '/peeps/users/:id' do
    @user = User.find(id: session[:user_id])
    @peeps = Peep.find_by(user_id: params[:id])
    @peep_user = User.find(id: params[:id])
    erb :'peeps/user'
  end

  post '/users' do
    registered_user = User.used_data?(username: params[:username], email: params[:email])
    if registered_user
      flash[:notice] = 'Username or email already in use'
      redirect '/users/new'
    else
      user = User.create(name: params[:name], username: params[:username], email: params[:email], password: params[:password])
      session[:user_id] = user.id
      redirect '/peeps'
    end
  end

  get '/sessions/new' do
    redirect '/peeps' if User.find(id: session[:user_id])
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(email: params[:email], password: params[:password])
    if user
      session[:user_id] = user.id
      redirect '/peeps'
    else
      flash[:notice] = 'Please check your email or password.'
      redirect '/sessions/new'
    end
  end

  delete '/sessions' do
    session.clear
    redirect '/peeps'
  end

  run! if app_file == $PROGRAM_NAME
end
