# Functions to make code more easyread.

def connect_to_db()
    db = SQLite3::Database.new('db/socialsDb.db')
    db.results_as_hash = true
    return db
end

def login_user(username, password)
    db = connect_to_db()
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    if BCrypt::Password.new(pwdigest) == password
        return result["id"]
    end
end

def register_user(username, password)
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/socialsDb.db')
    db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
end

def get_posts_for_user(user_id)
    
end

def new_post(user_id)
    
end

def edit_post
    
end

def get_a_post(user_id)
    
end

def delete_a_post(user_id)
    
end

