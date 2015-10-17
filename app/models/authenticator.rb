module Authenticator
  def self.is_logged_in(session)
    if session[:username] && User.where(:username => session[:username]).first
      return true
    end
    return false
  end  
  
  def self.register(params, session)
    @user = User.new()
    @user.username = params[:username]
    @user.password = params[:password]
    @user.email = params[:email]
    if @user.valid?
      @user.signed_up_on = DateTime.now
      @user.last_signed_in_on = @user.signed_up_on
      @user.save
      Rails.logger.info("Registered user: " + @user.to_json)
      session[:username] = @user.username
    else
      Rails.logger.info("Failed to register user: " + @user.to_json)
      raise StandardError, "Username or Email already in use."
    end
  end
  
  def self.log_in(params, session)
    username = params[:username]
    password = params[:password]
    user = User.authenticate_by_username(username, password)
    if user
      user.last_signed_in_on = DateTime.now
      user.save
      Rails.logger.info("Logged in user: " + username + ", userdata: " + @user.to_json)
      session[:username] = user.username
    else
      Rails.logger.info("Failed to login user: " + username + " with pw: " + password)
      raise StandardError, "Wrong username or password"
    end
  end
  
  def self.log_out(params, session)
    user = User.where(:username => session[:username]).first
    if user
      user.save
      Rails.logger.info("Logged out user: " + session[:username])
      session[:username] = nil
    else
      Rails.logger.info("Failed to log out user: " + session[:username])
      raise StandardError, "Failed to log out"
    end
  end
  
  def self.make_admin(params, session)
    self_user = User.where(:username => session[:username]).first
    other_username = params[:user][:username]
    if self_user && self_user.is_admin
      user = User.where(:username => other_username).first
      user.is_admin = true
      user.save
      Rails.logger.info("User #{self_user.username} made user #{other_username} admin")
    else
      Rails.logger.info("User #{self_user.username} failed to make user #{other_username} admin")
      raise StandardError, "Failed to make #{other_username} admin"
    end
  end

end