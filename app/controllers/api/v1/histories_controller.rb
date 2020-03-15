module Api::V1
  class HistoriesController < ApplicationController
    before_action :authenticate_api_v1_user!

    def index
      render json: {status: 'SUCCESS', data: {buy: JSON.parse(current_api_v1_user.buy_histories.to_json(except: [:updated_at], include: {item: {only: :name}})), sell: JSON.parse(current_api_v1_user.sell_histories.to_json(except: [:updated_at], include: {item: {only: :name}}))}}
    end
  end
end
