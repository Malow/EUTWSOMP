class RoleController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def create
    case params[:user_action]
    when 'create_role'
      create_role()
    when 'delete_role'
      delete_role()
    when 'change_role_preference'
      change_role_preference()
    else
      render json: {message: "Bad Action: " + params[:user_action]}, status: 500
      return
    end
  end
  
  private
  
  def create_role
    @user = User.where(:username => session[:username]).first
    if Authenticator.is_logged_in(session) && @user.is_admin
      begin
        @role = Role.new()
        @role.name = params[:role_name]
        @role.description = params[:role_description]
        if @role.valid?
          @role.save
          Rails.logger.info("Created Role: " + @role.to_json + " by " + session[:username])
          render json: {message: ""}, status: 200
          return
        end
      rescue StandardError => e
        Rails.logger.info("ERROR: Failed to create Role: " + params[:role_name].to_s + " by " + session[:username] + ". Error: ")
        Rails.logger.info(e.to_s)
        render json: {message: "Failed to create Role"}, status: 500
        return
      end
    else
      render json: {message: "User authentification failed"}, status: 500
      return
    end
  end
  
  def delete_role
    @user = User.where(:username => session[:username]).first
    if Authenticator.is_logged_in(session) && @user.is_admin
      begin
        @role = Role.where(:id => params[:role_id]).first
        if @role
          @role.destroy
          Rails.logger.info("Deleted Role: " + params[:role_id].to_s + " by " + session[:username])
          render json: {message: ""}, status: 200
          return
        end
      rescue StandardError => e
        Rails.logger.info("ERROR: Failed to delete Role: " + params[:role_id].to_s + " by " + session[:username] + ". Error: ")
        Rails.logger.info(e.to_s)
        render json: {message: "Failed to delete Role"}, status: 500
        return
      end
    else
      render json: {message: "User authentification failed"}, status: 500
      return
    end
  end
  
  def change_role_preference
    if Authenticator.is_logged_in(session)
      begin
        @user = User.where(:username => session[:username]).first
        @role_preference = RolePreference.where(:user_id => @user.id).where(:role_id => params[:role_id]).first
        if @role_preference
          if (@role_preference.preference + params[:amount].to_i) < 11 && (@role_preference.preference + params[:amount].to_i) > 0
            @role_preference.preference += params[:amount].to_i
            @role_preference.save
            Rails.logger.info("Updated RolePreference: " + @role_preference.to_json + " by " + session[:username])
          end
          render json: {message: ""}, status: 200
          return
        else
          @role_preference = RolePreference.new()
          @role_preference.user_id = @user.id
          @role_preference.role_id = params[:role_id]
          @role_preference.preference = 5
          if @role_preference.valid?
            @role_preference.save
            Rails.logger.info("Created RolePreference: " + @role_preference.to_json + " by " + session[:username])
            render json: {message: ""}, status: 200
            return
          end
        end
      rescue StandardError => e
        Rails.logger.info("ERROR: Failed to create/update RolePreference: " + params[:role_id].to_s + " by " + session[:username] + ". Error: ")
        Rails.logger.info(e.to_s)
        render json: {message: "Failed to create RolePreference"}, status: 500
        return
      end
    else
      render json: {message: "User authentification failed"}, status: 500
      return
    end
  end
 
end