class AccountController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def create
    begin
      case params[:user_action]
      when 'register'
        Authenticator.register(params, session)
      when 'log_in'
        Authenticator.log_in(params, session)
      when 'log_out'
        Rails.logger.info("Logged out user: #{session[:username]}")
        reset_session
      when 'change_password'
        Authenticator.change_password(params, session)
      when 'forgot_password'
        Authenticator.forgot_password(params, session)
      when 'reset_password'
        Authenticator.reset_password(params, session)
      when 'make_admin'
        Authenticator.make_admin(params, session)
      else
        render json: {message: "Bad Action: " + params[:user_action]}, status: 500
        return
      end
      render json: {message: ""}, status: 200
    rescue StandardError => e
      logger.error("Error in AccountController: " + e.to_s + "Trace: #{e}\n#{e.backtrace.join("\n")}")
      render json: {message: e.to_s}, status: 500
    end
  end
  
  def login
    gon.init = true
    if params[:error]
      gon.error = params[:error]
    end
    if Authenticator.is_logged_in(session)
      redirect_to root_path(:error => params[:error])
    else
      render("layouts/application")
    end
  end
  
  def register
    gon.init = true
    if params[:error]
      gon.error = params[:error]
    end
    if Authenticator.is_logged_in(session)
      redirect_to root_path(:error => params[:error])
    else
      render("layouts/application")
    end
  end
  
  def password_reset
    gon.init = true
    if params[:error]
      gon.error = params[:error]
    end
    token = params.first[0]
    @user = User.where(:password_reset_token => token).first
    if @user
      if @user.password_expires_after < DateTime.now
        @user.password_reset_token = nil
        @user.save
        redirect_to forgot_password_path(:error => "Password reset token has expired, please request a new one")
      else
        session[:password_reset_token] = @user.password_reset_token
        render("layouts/application")
      end
    else
      redirect_to root_path(:error => "Password reset token is invalid")
    end
  end
  
  private
 
end