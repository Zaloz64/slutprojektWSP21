require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions


get('/') do
    slim(:signIn)
end

# Logging in
post('/login') do
    username = params[:username]
    password = params[:password]
    session[:id] = login_user(username, password)
    if session[:id] != nil
      redirect('/media')
    else
      "login failed"
    end
end

get('/media') do
    id = session[:id].to_i
    slim(:"media/index",locals:{user:id})
end

# Register

get('/users/new') do

    username = params[:username]
    password = params[:password]
    password2 = params[:password2]
  
    if password == password2
      register_user(username, password)
      redirect('/')
    else
      "Lösenorden matchar inte"
    end
end
