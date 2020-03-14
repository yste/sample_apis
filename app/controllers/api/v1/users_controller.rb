module Api::V1
  class UsersController < ApplicationController
    def show
      render json: current_user.response_format
    end
  end
end
