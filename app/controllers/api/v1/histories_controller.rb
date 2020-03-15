module Api::V1
  class HistoriesController < ApplicationController
    before_action :authenticate_api_v1_user!

    def index
      render json: {status: 'SUCCESS', data: {buy: current_api_v1_user.buy_histories, sell: current_api_v1_user.sell_histories}}
    end
  end
end
