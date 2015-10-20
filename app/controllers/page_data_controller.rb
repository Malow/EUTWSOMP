require 'ostruct'

class PageDataController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  
  def create
    if Authenticator.is_logged_in(session)
      you = User.where(:username => session[:username]).select(:id, :username, :is_admin, :email).first
      page_data = OpenStruct.new
      page_data.has_updates = true
      page_data.you = you
      page_data.missions = Mission.all.select(:id, :name, :date, :creator_id, :created_at, :updated_at)
      page_data.participants = Participant.all.select(:mission_id, :user_id, :role, :slot_id, :joined_at, :is_mission_admin)
      page_data.users = User.all.select(:id, :username, :is_admin)
      render json: page_data, status: 200
    else
      page_data = OpenStruct.new
      page_data.has_updates = false
      render json: page_data, status: 200
    end

  end
  
  private
  
  

end