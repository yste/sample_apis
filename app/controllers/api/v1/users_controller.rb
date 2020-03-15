module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_api_v1_user!

    def index 
      render json: current_api_v1_user.to_json(except: [:encrypted_passworda, :tokens])
    end
  end
end
