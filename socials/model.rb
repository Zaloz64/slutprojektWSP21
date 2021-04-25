# Holds everyting 
module Model

    # Connects to the database
    def connect_to_db()
        db = SQLite3::Database.new('db/socialsDb.db')
        db.results_as_hash = true
        return db
    end

    # Cheacks if user is admin
    # @param [Integer] user_id Users id
    # @return [Bool]
    def isAdmin(user_id)
        db = connect_to_db()
        if db.execute('SELECT * FROM admin WHERE user_id = ?', user_id) == []
            return false
        else
            return true
        end
    end

    # Gets user from database
    # @param [String] username Users username
    # @param [String] password the accounts password
    # @return [Integer]
    # * :id [Integer] The ID of the user
    # @return [String] if user is not found (empty string)
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

    # Puts user in database
    # @param [String] username Users username
    # @param [String] password the accounts password
    # @return [True] if user found
    # @return [False] if user is not
    def register_user(username, password)
        db = connect_to_db()
        password_digest = BCrypt::Password.create(password)
        if db.execute('SELECT * FROM users WHERE username = ?', username) == []
            db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
            return false
        end
        return true
    end

    # Gets user
    # @param [Integer] user_id Users id
    # @return [Hash] 
    # * :id [Integer] The ID of the user
    # * :username [String] The username of the user
    # * :pwdigest [String] The password of the user
    # * :bio [String] The profile bio of the user
    # * :image [String] The src to the users photo
    def get_user(user_id)
        db = connect_to_db()
        username = db.execute('SELECT * FROM users WHERE id = ?',user_id).first
        return username
    end

    
    # Gets users post
    # @param [Integer] user_id Users id
    # @return [Array] with hashes
    # * :id [Integer] The ID of the post 
    # * :post [String] The src to the users photo
    # * :text [String] The posts text
    # * :date [String] The posts date
    def get_posts_for_user(user_id)
        db = connect_to_db()
        photos = db.execute('SELECT * FROM user_post_relation INNER JOIN posts ON user_post_relation.post_id = posts.id WHERE user_id = ?',user_id)
        return photos
    end

    # Gets all posts for the users feed
    # @param [Integer] id Users id
    # @return [Array] with hashes
    # * :id [Integer] The ID of the post 
    # * :post [String] The src to the users photo
    # * :text [String] The posts text
    # * :date [String] The posts date
    # * :username [String] The posts posters username
    # * :image [String] The users profileimage
    # * :bio [String] The users profile text
    def get_all_posts(id)
        db = connect_to_db()
        id = id['id'].to_i
        post_data = db.execute('SELECT DISTINCT posts.id, posts.date, posts.post, posts.text, followers.username, followers.img FROM users  
            JOIN users_relations ON users_relations.follower = users.id
            JOIN users as followers on users_relations.following = followers.id OR users.id
            JOIN user_post_relation on user_post_relation.user_id = followers.id 
            JOIN posts ON posts.id = user_post_relation.post_id
            WHERE users.id = ?
            ',id)
        return post_data.reverse!
    end

    # Puts a new post in the database with image
    # @param [Integer] user_id Users id
    # @param [String] post Posts src
    # @param [String] text Posts discription
    # @param [String] date Posts date
    def new_post_pic(user_id, post, text,date)
        db = connect_to_db()
        db.execute('INSERT INTO posts (post,text,date) VALUES (?,?,?)',post,text,date)
        post_id = db.execute('SELECT id FROM posts WHERE post = ?',post)
        db.execute('INSERT INTO user_post_relation (user_id,post_id) VALUES (?,?)',user_id, post_id[0].first[1])
    end

    # Puts a new post in the database without image
    # @param [Integer] user_id Users id
    # @param [String] text Posts discription
    # @param [String] date Posts date
    def new_post(user_id, text, date)
        db = connect_to_db()
        db.execute('INSERT INTO posts (post,text,date) VALUES (?,?,?)',"",text,date)
        post_id = db.execute('SELECT id FROM posts WHERE post = ?',"")
        db.execute('INSERT INTO user_post_relation (user_id,post_id) VALUES (?,?)',user_id, post_id[-1].first[1])
    end

    # Gets a post from its id
    # @param [Integer] post_id Posts id
    # @return [Hash]
    # * :id [Integer] The ID of the post 
    # * :post [String] The src to the users photo
    # * :text [String] The posts text
    # * :date [String] The posts date
    def get_a_post(post_id)
        db = connect_to_db()
        post = db.execute('SELECT * FROM posts WHERE id = ?',post_id)
        return post
    end

    # Gets user from post
    # @param [Integer] post_id Posts id
    # @return [Hash]
    # * :id [Integer] The ID of the user 
    # * :username [String] The username of the user
    def get_user_of_post(post_id)
        db = connect_to_db()
        user = db.execute('SELECT DISTINCT users.id, users.username FROM user_post_relation 
            JOIN users ON users.id = user_post_relation.user_id
            WHERE post_id = ?', post_id)
        return user
    end

    # Gets all users
    # @return [Array] with hashes
    # * :id [Integer] The ID of the user 
    # * :username [String] The username of the user
    # * :image [String] The users profileimage
    # * :bio [String] The users profile text
    def get_users()
        db = connect_to_db()
        users = db.execute('SELECT * FROM users')
        return users
    end

    # Attempts to delet a post
    # @param [Integer] post_id id of post
    def delete_a_post(post_id)
        db = connect_to_db()
        db.execute('DELETE FROM posts WHERE id = ?', post_id)
        db.execute('DELETE FROM user_post_relation WHERE post_id = ?', post_id)
        db.execute('DELETE FROM comment_post_relation WHERE post_id = ?', post_id)
        comment_id = db.execute('SELECT comment_id FROM comment_post_relation WHERE post_id = ?', post_id)
        comment_id.each do comment
            delete_comment(comment['comment_id'])
        end
    end

    # Likes or unlike a post
    # @param [Integer] post_id id of post
    # @param [Integer] user_id id of user
    def like_post(post_id, user_id)
        db = connect_to_db()
        if (db.execute('SELECT * FROM likes WHERE (user_id,post_id) = (?,?)', user_id,post_id) == [])
            db.execute('INSERT INTO likes (post_id,user_id) VALUES (?,?)', post_id, user_id)
        else
            db.execute('DELETE FROM likes WHERE (user_id,post_id) = (?,?)', user_id,post_id)
        end
    end

    # Gets coments from post
    # @param [Integer] post_id id of post
    # @return [Array] with hashes
    # * :id [Integer] The comments id
    # * :comment [String] The comments text
    # * :date [String] The comments date
    # * :username [String] The creater of the comments username
    def get_post_comments(post_id)
        db = connect_to_db()
        post = db.execute('SELECT comments.id, comments.comment, comments.date, users.username FROM comment_post_relation 
            JOIN comments ON comments.id = comment_post_relation.comment_id
            JOIN users ON users.id = comment_post_relation.user_id
            WHERE post_id = ?', post_id)
        return post
    end

    # Creates a new comment
    # @param [Integer] id The comments id
    # @param [String] comment The comments text
    # @param [String] date The comments date
    # @param [String] username The creater of the comments username
    def create_comment(comment, date, user_id, post_id)
        db = connect_to_db()
        db.execute('INSERT INTO comments (comment,date) VALUES (?,?)', comment,date)
        comment_id = db.execute('SELECT id FROM comments WHERE (comment,date) = (?,?)',comment,date)
        comment_id = comment_id[0]['id']
        db.execute('INSERT INTO comment_post_relation (user_id, comment_id, post_id) VALUES (?,?,?)' ,user_id,comment_id,post_id)
    end

    # Deletes a comment
    # @param [Integer] comment_id The comments id
    def delete_comment(comment_id)
        db = connect_to_db()
        db.execute('DELETE FROM comments WHERE id = ?', comment_id)
        db.execute('DELETE FROM comment_post_relation WHERE comment_id = ?', comment_id)
    end

    # Creates friends between people
    # @param [Integer] follower The followers id
    # @param [Integer] following The followings id
    def frendship_update(follower, following)
        db = connect_to_db()
        if db.execute('SELECT * FROM users_relations WHERE (follower, following) = (?,?)',follower,following) != []
            db.execute('DELETE FROM users_relations WHERE (follower, following) = (?,?)',follower,following)
        else
            db.execute('INSERT INTO users_relations (follower, following) VALUES (?,?)',follower,following)
        end
    end
    
    # Updates bio
    # @param [Integer] id The users id
    # @param [String] bio The bios new text
    def update_bio(id,bio)
        db = connect_to_db()
        db.execute('UPDATE users SET bio = ? WHERE id = ?',bio,id)
    end

    # Updates profile image
    # @param [Integer] id The users id
    # @param [String] img The imgage src
    def update_profile_img(id,img)
        db = connect_to_db()
        db.execute('UPDATE users SET img = ? WHERE id = ?',img,id)
    end
end