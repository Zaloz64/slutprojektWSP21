require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require "sinatra/json"
require 'json'
require_relative 'model.rb'

enable :sessions

before do
  @users = get_users()
end

get('') do
  slim(:layout)
end


get('/') do
  slim(:signIn, locals:{wrongPassword:session[:wrongPassword], coldownPassword:session[:coldownPassword]})
end

get('/posts/new') do
  slim(:"posts/new", locals:{picture:session[:picture]})
end

get('/posts/edit') do 
  slim(:"posts/edit", locals:{picture:session[:picture]})
end

get('/coldown') do
  slim(:coldown)
end

get('/media') do
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  allPosts = get_all_posts(username)
  users = get_users()
  slim(:"media/index",locals:{user:username, photos:posts, posts:allPosts,users:users})
end

get('/media/edit') do
  usernames = get_users()
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  # allPosts = get_all_posts(session[:id].to_i)
  slim(:"media/edit",locals:{user:username, users:usernames, photos:posts})
  # slim(:"media/index",locals:{user:username, users:usernames, photos:posts, posts:allPosts})

end

get('/media/profile') do 
  username = get_user(session[:id].to_i)
  # posts = get_posts_for_user(session[:id].to_i)
  posts = []
  slim(:"media/profile",locals:{user:username.first, photos:posts})
end


# Logging in
post('/login') do
  username = params[:username]
  password = params[:password]
  session[:picture] = "/img/image.png"
  if session[:lastlogin] == nil || Time.now - session[:lastlogin] > 1000
    if login_user(username, password) != "" 
      session[:id] = login_user(username, password)
      redirect('/media')
    end
    session[:lastlogin] = Time.now
    session[:wrongPassword] = true
  else
    session[:coldownPassword] = true
  end

  redirect('/')
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
  redirect('/posts/edit')
  # Need a rescue 
end

post('/posts/edit') do 
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

# See user

get('/user/') do
  "User cant be found"
end

get('/user/:id') do
  id = params[:id].to_i
  username = get_user(id)
  photos = get_posts_for_user(id)
  slim(:"user/show", locals:{photos:photos,user:username})
end

post('/user/:id/friendship') do 
  following = params[:id]
  follower = session[:id]
  frendship_update(follower, following)
  redirect("/user/#{following}")
end

# See post

get('/posts/:id') do
  id = params[:id].to_i
  post = get_a_post(id)
  comments = get_post_comments(id)
  user = get_user_of_post(id)
  theuser = get_user(session[:id].to_i)
  slim(:"posts/show", locals:{post:post,comments:comments, user:user, theuser:theuser})
end

post('/comments/:id/create') do
  comment = params[:comment]
  date = getDate()
  id = session[:id]
  post_id = params[:id].to_i
  create_comment(comment,date,id,post_id)
  redirect("/posts/#{post_id}")
end

post('/comments/:id/delete') do
  id = params[:id].to_i
  delete_comment(id)
  p id
  redirect('/media')
end

# like post

get('/media/like') do 
  post_id = params[:getpost].to_i
  user_id = session[:id]
  p post_id
  p user_id
  like_post(post_id, user_id)
  redirect('/media')
end









# Generera användare samt posts

post("/api/users") do
  payload = JSON.parse(request.body.read)
  username = payload['results'][0]['login']['username']
  password = payload['results'][0]['login']['password']
  register_user(username,password)
end

post('/api/users/post') do
  payload = JSON.parse(request.body.read)

end

