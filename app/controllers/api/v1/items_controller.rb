module Api::V1
  class ItemsController < ApplicationController
    before_action :authenticate_api_v1_user!
    before_action :set_params, only: [:create, :edit]

    def index
      @items = Item.where(create_user_id: current_api_v1_user.id)
      render json: { status: 'SUCCESS', data: @items}
    end

    def create
      @item = Item.create(@item_params.merge(create_user_id: current_api_v1_user.id))
      render json: { status: 'SUCCESS', data: @item }
    end

    def edit
    end

    def destory
    end

    def show
    end

    private
    def set_params
      @item_params = params.require(:item).permit(:name, :point)
    end
  end
end
