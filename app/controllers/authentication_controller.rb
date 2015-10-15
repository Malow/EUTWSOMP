class AuthenticationController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def is_logged_in_then_go_to_dashboard
    gon.init = true
    if session[:username] && User.where(:username => session[:username]).first
      redirect_to :root
    else
      gon.your_username = session[:username]
      render("layouts/application")
    end
  end
  
  def is_not_logged_in_then_go_to_login
    gon.init = true
    if session[:username] && User.where(:username => session[:username]).first
      gon.your_username = session[:username]
      render("layouts/application")
    else
      redirect_to '/login'
    end
  end
  
  def create
    case params[:user_action]
    when 'register'
      register(params)
    when 'log_in'
      log_in(params)
    when 'log_out'
      log_out(params)
    else
      render json: {message: "Bad Action: " + params[:user_action]}, status: 500
      return
    end
  end
  
  private
  
  def register(params)
    @user = User.new()
    @user.username = params[:username]
    @user.password = params[:password]
    @user.email = params[:email]
    if @user.valid?
      @user.signed_up_on = DateTime.now
      @user.last_signed_in_on = @user.signed_up_on
      logger.info("Regestering user: " + @user.to_json)
      @user.save
      session[:username] = @user.username
      gon.your_username = session[:username]
      render json: {message: ""}, status: 200
    else
      logger.info("Failed to register user: " + @user.to_json)
      render json: {message: "Username or Email already in use."}, status: 500
    end
  end
  
  def log_in(params)
    username = params[:username]
    password = params[:password]
    user = User.authenticate_by_username(username, password)
    logger.info(user.to_json)
    logger.info("Logging in user: " + username + ", userdata: " + @user.to_json)
    if user
      user.last_signed_in_on = DateTime.now
      user.save
      session[:username] = user.username
      gon.your_username = session[:username]
      render json: {message: ""}, status: 200
    else
      logger.info("Failed to login user: " + username + " with pw: " + password)
      render json: {message: "Wrong username or password"}, status: 500
    end
  end
  
  def log_out(params)
    user = User.where(:username => session[:username]).first
    if user
      user.save
      session[:username] = nil
      render json: {message: ""}, status: 200
    else
      logger.info("Failed to log out user: " + session[:username])
      render json: {message: "Failed to log out"}, status: 500
    end
  end

end