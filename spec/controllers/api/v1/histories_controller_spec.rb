require 'rails_helper'

RSpec.describe Api::V1::HistoriesController, type: :request do
  before do
    @owner_user = FactoryBot.create(:base_user)
    @other_user = FactoryBot.create(:base_user2)
    post "/api/v1/auth/sign_in", FactoryBot.attributes_for(:base_user)
    @headers = {
      'Content-Type' => 'application/json',
      'access-token' => response.header["access-token"],
      'client' => response.header["client"],
      'uid' => response.header["uid"]
    }

    # ユーザーの商品を作成する
    @owner_items = FactoryBot.build_list(:items, 5)
    @owner_items.each{|item| item.exhibit_flag = true; item.create_user_id = @owner_user.id; item.save}
    @other_items = FactoryBot.build_list(:items, 5)
    @other_items.each{|item| item.exhibit_flag = true; item.create_user_id = @other_user.id; item.save}

    # 売買履歴を作成する
    @owner_items.each do |item|
      Item.buy(item, @other_user)
    end
    @other_items.each do |item|
      Item.buy(item, @owner_user)
    end

    @owner_user.reload
    @buy_histories = JSON.parse(@owner_user.buy_histories.to_json(except: [:updated_at], include: {item: {only: :name}}))
    @sell_histories = JSON.parse(@owner_user.sell_histories.to_json(except: [:updated_at], include: {item: {only: :name}}))
  end

  it "show histories" do
    get "/api/v1/histories", headers: @headers
    expect(response.code).to eq("200")
    body = JSON.parse(response.body)
    expect(body["data"]["buy"]).to match_array(@buy_histories)
    expect(body["data"]["sell"]).to match_array(@sell_histories)
  end

  it "show unautholized histories" do
    get "/api/v1/histories"
    expect(response.code).to eq("401")
  end
end
