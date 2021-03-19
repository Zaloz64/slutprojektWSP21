require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions


get('/') do
  slim(:signIn)
end

get('/media/new') do
  slim(:"media/new", locals:{picture:session[:picture]})
end

get('/media/edit') do 
  slim(:"media/edit", locals:{picture:session[:picture]})
end

get('/media') do
  username = get_user(session[:id].to_i)
  # posts = get_posts_for_user()
  slim(:"media/index",locals:{user:username.first})
end


# Logging in
post('/login') do
  username = params[:username]
  password = params[:password]
  session[:id] = login_user(username, password)
  session[:picture] = "/img/image.png"
  if session[:id] != nil
    redirect('/media')
  else
    "login failed"
  end
end
# Register Borde vara en post=?????

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


# Uplode photo

post('/upload') do
  if params[:image] && params[:image][:filename]
    filename = params[:image][:filename]
    file = params[:image][:tempfile]
    path = "./public/uploads/#{filename}"
    session[:picture] = "/uploads/#{filename}"

    File.open(path, 'wb') do |f|
      f.write(file.read)
    end

    # add pathway user and stuffsssss.

  end
  redirect('/media/edit')
  # Need a rescue 
end

post('/media/edit') do 
  text = params[:description]
  time = Time.now
  date = "#{time.year}-#{time.month}-#{time.day}"
  new_post_pic(session[:id], session[:picture],text,date)
  redirect('/media')
end


