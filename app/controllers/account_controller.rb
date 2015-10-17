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
        Authenticator.log_out(params, session)
      when 'make_admin'
        Authenticator.make_admin(params, session)
      else
        render json: {message: "Bad Action: " + params[:user_action]}, status: 500
        return
      end
      render json: {message: ""}, status: 200
    rescue StandardError => e
      render json: {message: e.to_s}, status: 500
    end
  end
  
  def login
    if Authenticator.is_logged_in(session)
      redirect_to :root
    else
      render("layouts/application")
    end
  end
  
  def register
    if Authenticator.is_logged_in(session)
      redirect_to :root
    else
      render("layouts/application")
    end
  end
  
  private
 
end