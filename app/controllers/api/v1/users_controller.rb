module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_api_v1_user!

    def show
      render json: current_user.response_format
    end
  end
end
