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
  @isAdmin = isAdmin(session[:id])
end

get('') do
  slim(:layout)
end

get('/') do
  slim(:signIn, locals:{wrongPassword:session[:wrongPassword], coldownPassword:session[:coldownPassword], matchedPassword:session[:matchedPassword], isempty:session[:isempty],usernameExsists:session[:usernameExsists]})
end

get('/posts/new') do
  slim(:"posts/new", locals:{picture:session[:picture],nofoto:session[:nofoto]})
end

get('/posts/edit') do 
  slim(:"posts/edit", locals:{picture:session[:picture]})
end

get('/coldown') do
  slim(:coldown)
end

# Logging in 

post('/login') do
  username = params[:username]
  password = params[:password]
  session[:picture] = "/img/image.png"
  if session[:lastlogin] == nil || Time.now - session[:lastlogin] > 10
    if login_user(username, password) != "" 
      session[:id] = login_user(username, password)
      redirect('/media')
      session[:wrongPassword] = false
      session[:coldownPassword] = false
    end
    session[:lastlogin] = Time.now
    session[:wrongPassword] = true
    session[:coldownPassword] = false
  else
    session[:wrongPassword] = false
    session[:coldownPassword] = true
  end

  redirect('/')
end

get('/media') do
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  allPosts = get_all_posts(username)
  users = get_users()
  slim(:"media/index",locals:{user:username, photos:posts, posts:allPosts,users:users, emptyComment:session[:emptyComment]})
end

get('/media/edit') do
  username = get_user(session[:id].to_i)
  slim(:"media/edit",locals:{user:username})
end

get('/media/profile') do 
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  p posts
  slim(:"media/profile",locals:{user:username, photos:posts})
end

post('/users/new') do

  username = params[:username]
  password = params[:password]
  password2 = params[:password2]

  if !empty(username) && !empty(password) && !empty(password2)
    if password == password2
      session[:usernameExsists] = register_user(username, password)
    else
      session[:matchedPassword] = false
    end
  else
    session[:isempty] = true
  end
  redirect('/')
end


# Uplode photo

post('/upload') do
  if params[:image] == nil
    session[:nofoto] = true
    redirect('/posts/new')
  elsif params[:image] && params[:image][:filename]
    session[:nofoto] = false
    upload_img(params[:image][:filename], params[:image][:tempfile])
    redirect('/posts/edit')
  end
end

def upload_img(filename,file)
  path = "./public/uploads/#{filename}"
  session[:picture] = "/uploads/#{filename}"
  File.open(path, 'wb') do |f|
    f.write(file.read)
  end
end

post('/posts/edit') do 
  text = params[:description]
  date = getDate()
  new_post_pic(session[:id], session[:picture],text,date)
  redirect('/media')
end

post('/posts/:id/delete') do 
  id = params[:id].to_i
  delete_a_post(id)
  redirect('/media')
end

post('/create') do
  text = params[:textfield]
  if text != ""
    date = getDate()
    new_post(session[:id], text, date)
    session[:emptyComment] = false
  else
    session[:emptyComment] = true
  end
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
  the_user = get_user(session[:id])
  username = get_user(id)
  photos = get_posts_for_user(id)
  slim(:"user/show", locals:{photos:photos,user:username, the_user:the_user})
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
  redirect('/media')
end


get('/media/like') do 
  post_id = params[:getpost].to_i
  user_id = session[:id]
  like_post(post_id, user_id)
  redirect('/media')
end

post('/user/update') do
  bio = params[:bio]
  update_bio(session[:id], bio)
  redirect('/media')
end

post('/user/upload') do 
  if params[:image] && params[:image][:filename]
    upload_img(params[:image][:filename], params[:image][:tempfile])
  end
  update_profile_img(session[:id], session[:picture])
  redirect('/media')
end


get('/logout') do
  session[:id] = nil
  redirect('/')
end




def empty(string)
  if string.length() != 0
    return false
  end
  return true
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

