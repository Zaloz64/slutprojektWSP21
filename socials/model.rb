# Functions to make code more easyread.

def connect_to_db()
    db = SQLite3::Database.new('db/socialsDb.db')
    db.results_as_hash = true
    return db
end

# Loging in

def login_user(username, password)
    db = connect_to_db()
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    if result != nil
        pwdigest = result["pwdigest"]
        if BCrypt::Password.new(pwdigest) == password
            return result["id"]
        end
    end
    return ""
end

def register_user(username, password)
    db = connect_to_db()
    password_digest = BCrypt::Password.create(password)
    if db.execute('SELECT * FROM users WHERE username = ?', username) == []
        db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
        return false
    end
    return true
end

def get_user(user_id)
    db = connect_to_db()
    username = db.execute('SELECT * FROM users WHERE id = ?',user_id).first
    return username
end

def get_posts_for_user(user_id)
    db = connect_to_db()
    results_as_hash = true
    photos = db.execute('SELECT post FROM user_post_relation INNER JOIN posts ON user_post_relation.post_id = posts.id WHERE user_id = ?',user_id)
    return photos
end


# Behöver user, post comment ect
def get_all_posts(id)
    db = connect_to_db()
    id = id['id'].to_i
    post_data = db.execute('SELECT DISTINCT posts.id, posts.date, posts.post, posts.text, followers.username, followers.id FROM users  
        JOIN users_relations ON users_relations.follower = users.id
        JOIN users as followers on users_relations.following = followers.id
        JOIN user_post_relation on user_post_relation.user_id = followers.id 
        JOIN posts ON posts.id = user_post_relation.post_id
        WHERE users.id = ?
        ',id)
    p post_data
    # post_data = db.execute('')
    # post_data = db.execute('SELECT posts.id, posts.post, posts.text, posts.date, users.id, users.username FROM ((users_relations INNER JOIN users ON users_relations.following = users.id) INNER JOIN posts ON user_post_relation.user_id = users_relations.following) WHERE following = ?',id)
    # return post_data
    return post_data
end

def new_post_pic(user_id, post, text,date)
    db = connect_to_db()
    db.execute('INSERT INTO posts (post,text,date) VALUES (?,?,?)',post,text,date)
    post_id = db.execute('SELECT id FROM posts WHERE post = ?',post)
    db.execute('INSERT INTO user_post_relation (user_id,post_id) VALUES (?,?)',user_id, post_id[0].first[1])
end

def new_post(user_id, text, date)
    db = connect_to_db()
    db.execute('INSERT INTO posts (post,text,date) VALUES (?,?,?)',"",text,date)
    post_id = db.execute('SELECT id FROM posts WHERE post = ?',"")
    db.execute('INSERT INTO user_post_relation (user_id,post_id) VALUES (?,?)',user_id, post_id[-1].first[1])
end

def edit_post
    
end

def get_a_post(post_id)
    db = connect_to_db()
    post = db.execute('SELECT * FROM posts WHERE id = ?',post_id)
    return post
end

def get_user_of_post(post_id)
    db = connect_to_db()
    results_as_hash = true
    user_id = db.execute('SELECT user_id FROM user_post_relation WHERE post_id = ?',post_id)
    user = db.execute('SELECT * FROM users WHERE id = ?',user_id[0]['user_id'])
    return user
end

def get_users()
    db = connect_to_db()
    users = db.execute('SELECT * FROM users')
    return users
end

def delete_a_post(user_id)
    
end

def like_post(post_id, user_id)
    db = connect_to_db()
    if (db.execute('SELECT * FROM likes WHERE (user_id,post_id) = (?,?)', user_id,post_id) == [])
        db.execute('INSERT INTO likes (post_id,user_id) VALUES (?,?)', post_id, user_id)
    else
        db.execute('DELETE FROM likes WHERE (user_id,post_id) = (?,?)', user_id,post_id)
    end
end


# kan ha många komentarer....
def get_post_comments(post_id)
    db = connect_to_db()
    post_relation = db.execute('SELECT * FROM comment_post_relation WHERE post_id = ?',post_id)
    post = []
    post_relation.each do |comment|
        comment_id = comment['comment_id']
        post << db.execute('SELECT * FROM comments WHERE id = ?',comment_id)
    end
    return post
end

def create_comment(comment, date, user_id, post_id)
    db = connect_to_db()
    db.execute('INSERT INTO comments (comment,date) VALUES (?,?)', comment,date)
    comment_id = db.execute('SELECT id FROM comments WHERE (comment,date) = (?,?)',comment,date)
    comment_id = comment_id[0]['id']
    db.execute('INSERT INTO comment_post_relation (user_id, comment_id, post_id) VALUES (?,?,?)' ,user_id,comment_id,post_id)
end

def delete_comment(comment_id)
    db = connect_to_db()
    db.execute('DELETE FROM comments WHERE id = ?', comment_id)
    db.execute('DELETE FROM comment_post_relation WHERE comment_id = ?', comment_id)
end


def frendship_update(follower, following)
    db = connect_to_db()
    if db.execute('SELECT * FROM users_relations WHERE (follower, following) = (?,?)',follower,following) != []
        db.execute('DELETE FROM users_relations WHERE (follower, following) = (?,?)',follower,following)
    else
        db.execute('INSERT INTO users_relations (follower, following) VALUES (?,?)',follower,following)
    end
end

