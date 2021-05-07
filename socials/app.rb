require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require "sinatra/json"
require 'json'
require_relative 'model.rb'

enable :sessions

include Model

# Before lodaing page gets:
# All users
# Cheacks to see if user is admin
before do
  if (session[:id] == nil) && (request.path_info != "/") && (request.path_info != "/login")
    redirect('/')
  end
  @users = get_users()
  @isAdmin = isAdmin(session[:id])
end

# Landing page
get('/') do
  slim(:signIn, locals:{wrongPassword:session[:wrongPassword], coldownPassword:session[:coldownPassword], matchedPassword:session[:matchedPassword], isempty:session[:isempty],usernameExsists:session[:usernameExsists]})
end

# Create new post
get('/posts/new') do
  slim(:"posts/new", locals:{picture:session[:picture],nofoto:session[:nofoto]})
end

# Edit new post
get('/posts/edit') do 
  slim(:"posts/edit", locals:{picture:session[:picture]})
end


# Attempts to login into the application
# @param [String] username användarnamnet
# @param [String] password användarnamnet
# * :error [Boolean] whether there was an empty input 
# * :error [Boolean] whether it was the wrong password or username 
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

# Attempts to sign up a new user
# @param [String] username användarens namn
# @param [String] password lösenord
# @param [String] password2 confirmation av lösenord
# If eny errors accour it redirects to the log in page with:
# * :error [Boolean] whether there was an empty input 
# * :error [Boolean] whether passwords did not match 
# * :error [Boolean] whether the username is already used 
post('/users/new') do 

  username = params[:username]
  password = params[:password]
  password2 = params[:password2]

  if !empty(username) && !empty(password) && !empty(password2)
    if password == password2
      session[:usernameExsists] = register_user(username, password)
    else
      session[:matchedPassword] = false
      session[:isempty] = false
    end
  else
    session[:matchedPassword] = true
    session[:isempty] = true
  end
  redirect('/')
end

# Shows posts 
# @param [Hash] username användarens info
# @param [Hash] allPosts alla posts från följare inklusive sig själv
get('/media') do
  username = get_user(session[:id].to_i)
  allPosts = get_all_posts(username)
  slim(:"media/index",locals:{user:username, posts:allPosts, emptyComment:session[:emptyComment]})
end

# Costumises the users profile
# @param [Hash] username användarens info
get('/media/edit') do
  username = get_user(session[:id].to_i)
  slim(:"media/edit",locals:{user:username})
end

# Shows the users profile
# @param [Hash] username användarens info
# @param [Hash] posts användarens posts
get('/media/profile') do 
  username = get_user(session[:id].to_i)
  posts = get_posts_for_user(session[:id].to_i)
  slim(:"media/profile",locals:{user:username, photos:posts})
end

# Chooses the image to upload
# Trys to redirects to posts edit unless Image is empty
# @param [String] Image
# @param [String] Filename
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

# Upload image to the project folder
# @param [String] filename The filename
# @param [String] file The file
def upload_img(filename,file)
  path = "./public/uploads/#{filename}"
  session[:picture] = "/uploads/#{filename}"
  File.open(path, 'wb') do |f|
    f.write(file.read)
  end
end

# Upload image to the feed with discripton and date
# Redirects to media
# @param [String] text Photo discription
# @param [String] date The date of the photo uploaded
post('/posts/edit') do 
  text = params[:description]
  date = getDate()
  new_post_pic(session[:id], session[:picture],text,date)
  redirect('/media')
end

# get('/posts/:id/delete') do
#   redirect('/media')
# end

# Delets a post
# Redirects to media
# @param [Integer] id The id of the post
post('/posts/:id/delete') do 
  id = params[:id].to_i
  user = get_user_of_post(id)
  
  if user[0]['id'] == session[:id] && @isAdmin
    delete_a_post(id)
  end

  redirect('/media')
end

# Creates a post with only text
# Redirects to media
# @param [String] text Post text
# * :error [Boolean] whether there was an empty input 
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

# Creates a string with the date
# @return [String] date The current date
def getDate()
  time = Time.now
  date = "#{time.year}-#{time.month}-#{time.day}"
  return date
end

# Shows a specific users profile
# @param [Integer] id The id of the user
# @param [Hash] the_user The users information
# @param [Hash] username The specific users information
# @param [Hash] photos The specific users posts
get('/user/:id') do
  id = params[:id].to_i
  the_user = get_user(session[:id])
  username = get_user(id)
  photos = get_posts_for_user(id)
  slim(:"user/show", locals:{photos:photos,user:username, the_user:the_user})
end

# Updates the friendship relationship
# @param [Integer] following The id of the loged in user
# @param [Integer] followier The id of the other user
post('/user/:id/friendship') do 
  following = params[:id]
  follower = session[:id]
  frendship_update(follower, following)
  redirect("/user/#{following}")
end

# Shows the posts comments and the post
# @param [Integer] id The id of the post
# @param [Hash] post The posts information
# @param [Hash] comments The posts comments
# @param [Hash] user the posts user
# @param [Hash] theuser the user
get('/posts/:id') do
  id = params[:id].to_i
  post = get_a_post(id)
  comments = get_post_comments(id)
  user = get_user_of_post(id)
  theuser = get_user(session[:id].to_i)
  slim(:"posts/show", locals:{post:post,comments:comments, user:user, theuser:theuser})
end

# Creates a new comment
# @param [String] comment The text of the comment
# @param [String] date When the comment was written
# @param [Integer] id The users id
# @param [Integer] post_id The comments id
post('/comments/:id/create') do
  comment = params[:comment]
  date = getDate()
  id = session[:id]
  post_id = params[:id].to_i
  create_comment(comment,date,id,post_id)
  redirect("/posts/#{post_id}")
end

# Delets a comment
# @param [Integer] post_id The comments id
post('/comments/:id/delete') do
  id = params[:id].to_i
  if is_owner_of_comment(id, session[:id]) || @isAdmin
    delete_comment(id)
  end
  redirect('/media')
end

# Likes a post
# @param [Integer] user_id The users id
# @param [Integer] post_id The posts id
get('/media/like') do 
  post_id = params[:getpost].to_i
  user_id = session[:id]
  like_post(post_id, user_id)
  redirect('/media')
end

# Updates profile bio
# @param [String] bio The discripton of the profild
post('/user/update') do
  bio = params[:bio]
  update_bio(session[:id], bio)
  redirect('/media')
end

# Uploads a new profile image
# @param [String] Image
# @param [String] Filename
post('/user/upload') do 
  if params[:image] && params[:image][:filename]
    upload_img(params[:image][:filename], params[:image][:tempfile])
  end
  update_profile_img(session[:id], session[:picture])
  redirect('/media')
end

# Logs out a user
get('/logout') do
  session[:id] = nil
  redirect('/')
end


# Cheacks if a string is emptu
# @return [bool]
def empty(string)
  if string.length() != 0
    return false
  end
  return true
end

# Generera användare
post("/api/users") do
  payload = JSON.parse(request.body.read)
  username = payload['results'][0]['login']['username']
  password = payload['results'][0]['login']['password']
  
  picture = payload['results'][0]['picture']['medium']
  temp = payload['results'][0]['name']
  discription = "#{temp['title']} #{temp['first']} #{temp['last']}"

  register_user(username,password)
  id = (get_userid(username))[0]['id']
  update_bio(id, discription)
  update_profile_img(id, picture)

  p "------------------ Saved ------------------------------"
end

# Genererar posts
post('/api/users/post') do
  payload = JSON.parse(request.body.read)
  username = payload[0]
  img_url = payload[1]
  quote = payload[2]

  id = (get_userid(username))[0]['id']
  date = getDate()
  new_post_pic(id, img_url, quote, date)
end

