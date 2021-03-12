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
  slim(:"media/new")
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
  username = get_user(id)
  slim(:"media/index",locals:{user:username.first})
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

post ('/upload') do
  # Check if user uploaded a file
  if params[:image] && params[:image][:filename]
    filename = params[:image][:filename]
    file = params[:image][:tempfile]
    path = "./public/uploads/#{filename}"

    # Write file to disk
    File.open(path, 'wb') do |f|
      f.write(file.read)
    end
  end

  redirect('uplod/edit')

end

get('/uplod/edit') do 
  

end

