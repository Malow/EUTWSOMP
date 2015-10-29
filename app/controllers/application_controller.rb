class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def index
    gon.init = true
    if params[:error]
      gon.error = params[:error]
    end
    if Authenticator.is_logged_in(session)
      render("layouts/application")
    else
      redirect_to login_path(:error => params[:error])
    end
  end
end
