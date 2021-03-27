require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require "sinatra/json"
require 'json'
# require "execjs"
require_relative 'model.rb'

enable :sessions

get('') do
  users = get_users()
  slim(:layout, locals:{users:users})
end
  
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
  usernames = get_users()
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  allPosts = get_all_posts()
  slim(:"media/index",locals:{user:username.first, users:usernames, photos:posts, posts:allPosts})
  # slim(:"media/index",locals:{user:username, users:usernames, photos:posts, posts:allPosts})

end

get('/media/profile') do 
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  slim(:"media/profile",locals:{user:username.first, photos:posts})
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

post("/api/users") do
  payload = JSON.parse(request.body.read)
  pp payload
  # username = payload['results'][0]['login']['username']
  # password = payload['results'][0]['login']['password']
  # register_user(username,password)
end

get('/users/new') do

  username = params[:username]
  password = params[:password]
  password2 = params[:password2]
  
  if password == password2
    register_user(username, password)
    redirect('/')
  else
    # context = getJSFile()
    # context.call()
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
  date = getDate()
  new_post_pic(session[:id], session[:picture],text,date)
  redirect('/media')
end

post('/create') do
  text = params[:textfield]
  date = getDate()
  new_post(session[:id], text, date)
  redirect('/media')
end


def getDate()
  time = Time.now
  date = "#{time.year}-#{time.month}-#{time.day}"
  return date
end

def getJSFile()
  source = open('/js/script.js').read
  context = ExecJS.compile(source)
  return context
end

