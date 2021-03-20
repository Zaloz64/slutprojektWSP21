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

def get_user(user_id)
    db = connect_to_db()
    username = db.execute('SELECT username FROM users WHERE id = ?',user_id).first
    return username
end

def get_posts_for_user(user_id)
    db = connect_to_db()
    results_as_hash = true
    photos = db.execute('SELECT post FROM user_post_relation INNER JOIN posts ON user_post_relation.post_id = posts.id WHERE user_id = ?',user_id)
    return photos
end

def new_post_pic(user_id, post, text,date)
    db = connect_to_db()
    db.execute('INSERT INTO posts (post,text,date) VALUES (?,?,?)',post,text,date)
    post_id = db.execute('SELECT id FROM posts WHERE post = ?',post)
    db.execute('INSERT INTO user_post_relation (user_id,post_id) VALUES (?,?)',user_id, post_id[0].first[1])
end

def edit_post
    
end

def get_a_post(user_id)
    
end

def get_users()
    db = connect_to_db()
    users = db.execute('SELECT username FROM users')
    return users
end

def delete_a_post(user_id)
    
end

