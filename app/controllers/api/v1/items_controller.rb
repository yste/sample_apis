module Api::V1
  class ItemsController < ApplicationController
    before_action :authenticate_api_v1_user!, except: [:search]
    before_action :set_params, only: [:create, :update]
    before_action :get_my_item, only: [:update, :destroy, :change_exhibit]
    before_action :get_item, only: [:buy]

    def index
      @items = Item.where(create_user_id: current_api_v1_user.id)
      render json: { status: 'SUCCESS', data: @items}
    end

    def create
      @item = Item.create(@item_params.merge(create_user_id: current_api_v1_user.id))
      render json: { status: 'SUCCESS', data: @item }
    end

    def update
      @item.update!(@item_params)
      render json: { status: 'SUCCESS', data: @item }
    rescue => e
      render json: {status: 'ERROR', message: e.message}, status: 400
    end

    def change_exhibit
      @item.exhibit_flag = !@item.exhibit_flag
      @item.save!
      render json: { status: 'SUCCESS' }
    rescue => e
      render json: {status: 'ERROR', message: e.message}, status: 400
    end

    def buy
      begin
        Item.buy(@item, current_api_v1_user)
      rescue => e
        render json: { status: 'ERROR', message: e.message }, status: 400
        return
      end
      render json: { status: 'SUCCESS' }
    end

    def destroy 
      if @item.buy_user_id.present?
        render json: { status: 'ERROR', message: "売却した商品は削除出来ません"}, status: 400
        return
      end
      if @item.exhibit_flag
        render json: { status: 'ERROR', message: "出品中の商品は削除出来ません"}, status: 400
        return
      end
      @item.destroy!
      render json: { status: 'SUCCESS' }
    rescue => e
      render json: { status: 'ERROR', message: e.message }, status: 400
    end

    def search
      if api_v1_user_signed_in?
        items = Item.where.not(create_user_id: current_api_v1_user.id).paginate(page: params[:page])
      else
        items = Item.paginate(page: params[:page].try(:to_i))
      end
      render json: { status: 'SUCCESS', data: items } 
    end

    private
    def set_params
      @item_params = params.require(:item).permit(:name, :point)
    end

    def get_my_item
      @item = Item.where(id: params[:id].to_i, create_user_id: current_api_v1_user.id).first
      if @item.blank?
        render json: { status: 'ERROR'}, status: 404
        return
      end
    end

    def get_item
      @item = Item.where(id: params[:id]).first
      if @item.blank?
        render json: { status: 'ERROR'}, status: 404
        return
      end
    end
  end
end
