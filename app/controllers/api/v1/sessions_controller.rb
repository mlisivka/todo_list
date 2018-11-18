class Api::V1::SessionsController < ApplicationController
  include Api::V1::SessionsDoc
  skip_before_action :authenticate_request

  def create
    command = AuthenticateUser.call(params[:username], params[:password])

    if command.success?
      response.headers['Authorization'] = command.result
      render json: {}
    end
  end
end
