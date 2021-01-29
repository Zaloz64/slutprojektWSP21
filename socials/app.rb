require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions


get('/') do
    slim(:signIn)
end

# Logging in
post('/login') do
    username = params[:username]
    password = params[:password]
    db = getDb()
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/media')
    else
      "fel lösenord"
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
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/socialsDb.db')
      db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
      redirect('/')
    else
      "Lösenorden matchar inte"
    end
end

# Functions to make code more easyread.

def getDb()
    db = SQLite3::Database.new('db/socialsDb.db')
    db.results_as_hash = true
    return db
end

