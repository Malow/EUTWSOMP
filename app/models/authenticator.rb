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
    @user.password = AESEncryption.encrypt(params[:password])
    @user.email = params[:email]
    if @user.valid?
      @user.signed_up_on = DateTime.now
      @user.last_signed_in_on = @user.signed_up_on
      @user.save
      Rails.logger.info("Registered user: #{@user.to_json}")
      session[:username] = @user.username
    else
      Rails.logger.info("Failed to register user: #{@user.to_json}")
      raise StandardError, "Username or Email already in use."
    end
  end
  
  def self.log_in(params, session)
    username = params[:username]
    password = AESEncryption.encrypt(params[:password])
    user = User.authenticate_by_username(username, password)
    if user
      user.last_signed_in_on = DateTime.now
      user.save
      Rails.logger.info("Logged in user: #{username}, userdata: #{@user.to_json}")
      session[:username] = user.username
    else
      Rails.logger.info("Failed to login user: #{username} with pw: #{password}")
      raise StandardError, "Wrong username or password"
    end
  end
  
  def self.change_password(params, session)
    username = session[:username]
    old_password = AESEncryption.encrypt(params[:old_password])
    new_password = AESEncryption.encrypt(params[:new_password])
    user = User.authenticate_by_username(username, old_password)
    if user
      user.password = new_password
      user.save
      Rails.logger.info("Password changed for user: #{username}, userdata: #{@user.to_json}")
    else
      Rails.logger.info("Failed to change password for user: #{username} with pw: #{old_password}")
      raise StandardError, "Wrong username or password"
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
  
  def self.forgot_password(params, session)
    user = User.where(:username => params[:username]).first
    if user
      user.password_reset_token = SecureRandom.urlsafe_base64
      user.password_expires_after = 24.hours.from_now
      user.save
      UserMailer.reset_password_email(user).deliver
    else
      Rails.logger.info("Password forgot failed, User #{params[:username]} not found")
      raise StandardError, "User #{params[:username]} not found"
    end
  end
  
  def self.reset_password(params, session)
    token = session[:password_reset_token]
    @user = User.where(:password_reset_token => token).first
    if @user
      if @user.password_expires_after < DateTime.now
        @user.password_expires_after = nil
        @user.password_reset_token = nil
        @user.save
        Rails.logger.info("Password reset failed for #{user.to_json}: token expired")
        raise StandardError, "Password reset token has expired"
      else
        @user.password_expires_after = nil
        @user.password_reset_token = nil
        @user.password = AESEncryption.encrypt(params[:new_password])
        @user.save
        session[:password_reset_token] = nil
        Rails.logger.info("Password sucessfully reset for #{@user.to_json}")
      end
    else
      Rails.logger.info("Password reset failed, token not valid")
      raise StandardError, "Password reset token not valid"
    end
  end

end