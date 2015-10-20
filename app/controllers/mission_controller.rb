class MissionController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  
  def create
    case params[:mission_action]
    when 'create'
      create_mission()
    when 'join'
      join_mission()
    when 'make_mission_admin'
      make_mission_admin()
    else
      render json: {message: "Bad Action: " + params[:user_action]}, status: 500
      return
    end
  end
  
  private
  
  def create_mission
    if Authenticator.is_logged_in(session)
      begin
        @mission = Mission.new()
        @mission.name = params[:mission][:name]
        @mission.date = params[:mission][:date]
        @mission.created_at = DateTime.now
        @mission.updated_at = DateTime.now
        @mission.creator = User.where(:username => session[:username]).first
        if @mission.valid?
          @mission.save
          Rails.logger.info("Created mission: " + @mission.to_json + " by " + session[:username])
          render json: {id: @mission.id}, status: 200
          return
        end
      rescue StandardError => e
        Rails.logger.info("ERROR: Failed to create mission: " + @mission.to_json + " by " + session[:username] + ". Error: ")
        Rails.logger.info(e.to_s)
        render json: {message: "Failed to create mission"}, status: 500
      end
    end
  end
  
  def join_mission
    if Authenticator.is_logged_in(session)
      begin
        @participant = Participant.new()
        @participant.mission = Mission.where(:id => params[:mission_id]).first
        @participant.user = User.where(:username => session[:username]).first
        @participant.role = "Gunner"
        @participant.slot_id = 2
        @participant.joined_at = DateTime.now
        @participant.is_mission_admin = false
        if @participant.valid?
          @participant.save
          Rails.logger.info("Created participant: " + @participant.to_json + " by " + session[:username])
          render json: {message: ""}, status: 200
          return
        else
          raise StandardError, "Participant not valid"
        end
      rescue StandardError => e
        Rails.logger.info("ERROR: Failed to create participant: " + @participant.to_json + " by " + session[:username] + ". Error: ")
        Rails.logger.info(e.to_s)
        render json: {message: "Failed to create participant"}, status: 500
      end
    end
  end
  
  def make_mission_admin
    self_user = User.where(:username => session[:username]).first
    other_user = User.where(:id => params[:user_id]).first
    mission = Mission.where(:id => params[:mission_id]).first
    if self_user && other_user && mission
      self_participant = Participant.where(:user_id => self_user.id).where(:mission_id => mission.id).first
      if self_user.is_admin || mission.creator_id == self_user.id || self_participant.is_mission_admin
        other_participant = Participant.where(:user_id => other_user.id).where(:mission_id => mission.id).first
        if other_participant
          other_participant.is_mission_admin = true
          other_participant.save
          Rails.logger.info("User #{self_user.username} made user #{other_user.username} mission-admin of mission #{mission.name}")
          render json: {message: ""}, status: 200
          return
        end
      end
    end
    Rails.logger.info("ERROR: Failed to make user: " + other_user.username + " mission-admin for mission " + mission.name + " by user: " + session[:username])
    render json: {message: "Failed to make participant mission-admin"}, status: 500
  end
  

end