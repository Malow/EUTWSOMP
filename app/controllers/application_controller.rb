require 'gon'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def index
    gon.init = true
    if session[:username]
      gon.your_username = session[:username]
      render("layouts/application")
    else
      redirect_to "/login"
    end
  end
end
