module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_api_v1_user!

    def index 
      render json: {status: 'SUCCESS', data: JSON.parse(current_api_v1_user.to_json(except: [:encrypted_password, :tokens]))}
    end
  end
end
