class MissionController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  
  def create
    case params[:mission_action]
    when 'create'
      create_mission()
    when 'join'
      join_mission()
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
        raise e
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
        raise e
      end
    end
  end
  

end