# frozen_string_literal: true

class Api::V1::RegistrationsController < ApplicationController
  include Api::V1::RegistrationsDoc
  skip_before_action :authenticate_request

  def create
    @user = User.new(user_params)
    @user.uid = SecureRandom.uuid

    if @user.save
      render json: json_resource(Api::V1::UserResource, @user),
             status: :created
    else
      respond_with_errors(@user)
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
