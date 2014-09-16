require 'wake_me_app/api/v1/mobile_formatter'

class Api::V1::UsersController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token
  #before_filter :authenticate_user!

  def show
    @user = User.find(params["id"])
    if @user
      render :json=> {:success => true, :user=>format_user_profile(@user)}
      return
    end
    failure 
  end

  def update
    @user = User.find(params["id"])
    if current_user.update(user_params)
      render :json=> {:success => true, :user=>format_user_profile(current_user)}
      return
    end
    failure
  end

  def failure
    return render json: { success: false, errors: [t('api.v1.sessions.invalid_login')] }, :status => :unauthorized
  end

  def format_user_profile(user)
    ::WakeMeApp::MobileFormatter.new(user.alarms.turned_on).format_user_profile(user, current_user)
  end

  private

  def user_params
    params.permit(:profile_image_url)
  end
end
