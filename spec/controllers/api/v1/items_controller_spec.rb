require 'rails_helper'

RSpec.describe Api::V1::ItemsController, type: :request do
  before do
    @user = FactoryBot.create(:base_user)
    post "/api/v1/auth/sign_in", FactoryBot.attributes_for(:base_user)
    @headers = {
      'Content-Type' => 'application/json',
      'access-token' => response.header["access-token"],
      'client' => response.header["client"],
      'uid' => response.header["uid"]
    }
  end

  describe "show items" do
    it "empty item" do
      get "/api/v1/items", headers: @headers
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)["status"]).to eq("SUCCESS")
      expect(JSON.parse(response.body)["data"]).to be_empty
    end

    it "show items" do
      item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id))
      get "/api/v1/items", headers: @headers
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)["status"]).to eq("SUCCESS")
      expect(JSON.parse(response.body)["data"]).to_not be_empty
      expect(JSON.parse(response.body)["data"][0]["name"]).to eq(item.name)
    end
  end

  it "create items" do
    post "/api/v1/items", params: FactoryBot.attributes_for(:item1).to_json, headers: @headers
    expect(response.code).to eq("200")
  end

  describe "edit items" do
    before do
      @user2 = FactoryBot.create(:base_user2)
      @owner_item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id))
      @other_item = Item.create(FactoryBot.attributes_for(:item2).merge(create_user_id: @user2.id))
    end

    it "owner item edit" do
      edit_param = {name: "商品名変更"}
      put "/api/v1/items/#{@owner_item.id}", params: edit_param.to_json, headers: @headers
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)["data"]["name"]).to eq(edit_param[:name])
      @owner_item.reload
      expect(@owner_item.name).to eq(edit_param[:name])
    end

    it "other user item edit" do
      edit_param = {name: "商品名変更"}
      put "/api/v1/items/#{@other_item.id}", params: edit_param.to_json, headers: @headers
      expect(response.code).to eq("404")
      expect(JSON.parse(response.body)["status"]).to eq("ERROR")
    end

    it "owner item exhibit on" do
      post "/api/v1/items/#{@owner_item.id}/change_exhibit", headers: @headers
      expect(response.code).to eq("200")
      @owner_item.reload
      expect(@owner_item.exhibit_flag).to eq(true)
    end
    
    it "owner item exhibit off" do
      @owner_item.exhibit_flag = true
      @owner_item.save
      post "/api/v1/items/#{@owner_item.id}/change_exhibit", headers: @headers
      expect(response.code).to eq("200")
      @owner_item.reload
      expect(@owner_item.exhibit_flag).to eq(false)
    end

    it "other user item exhibit" do
      post "/api/v1/items/#{@other_item.id}/change_exhibit", headers: @headers
      expect(response.code).to eq("404")
      expect(JSON.parse(response.body)["status"]).to eq("ERROR")
    end

  end

  describe "delete items" do
    before do
      @user2 = FactoryBot.create(:base_user2)
      @owner_item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id))
      @other_item = Item.create(FactoryBot.attributes_for(:item2).merge(create_user_id: @user2.id))
    end
    it "owner item delete" do
      delete "/api/v1/items/#{@owner_item.id}", headers: @headers
      expect(response.code).to eq("200")
      item = Item.find_by id: @owner_item.id
      expect(item).to eq(nil)
    end

    it "owner exhibit item delete" do
      @owner_item.exhibit_flag = true
      @owner_item.save
      delete "/api/v1/items/#{@owner_item.id}", headers: @headers
      expect(response.code).to eq("400")
      expect(JSON.parse(response.body)["message"]).to eq("出品中の商品は削除できません")
    end

    it "other user item delete" do
      delete "/api/v1/items/#{@other_item.id}", headers: @headers
      expect(response.code).to eq("404")
    end
  end

  describe "buy items" do
    before do
      @user2 = FactoryBot.create(:base_user2)
      @target_item = Item.create(FactoryBot.attributes_for(:item2).merge(create_user_id: @user2.id, exhibit_flag: true))
      @owner_item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id))
      @user3 = FactoryBot.create(:base_user3)
    end

    it "buy item" do
      post "/api/v1/items/#{@target_item.id}/buy", headers: @headers
      expect(response.code).to eq("200")
      @user.reload
      expect(@user.point).to eq(1000 - @target_item.point)
      expect(@user.buy_items.first).to eq(@target_item)
      @user2.reload
      expect(@user2.point).to eq(1000 + @target_item.point)
      expect(@user2.sell_items.first).to eq(@target_item)
    end

    it "buy owner item" do
      post "/api/v1/items/#{@owner_item.id}/buy", headers: @headers
      expect(response.code).to eq("400")
      expect(JSON.parse(response.body)["message"]).to eq("自身が登録した商品は購入できません")
    end

    it "edit and buy item to exhibit_flag off" do
      @target_item.update({exhibit_flag: false})
      post "/api/v1/items/#{@target_item.id}/buy", headers: @headers
      expect(response.code).to eq("400")
      expect(JSON.parse(response.body)["message"]).to eq("この商品は購入できません")
    end

    it "buy to point over item" do
      @target_item.update({point: 10000})
      post "/api/v1/items/#{@target_item.id}/buy", headers: @headers
      expect(response.code).to eq("400")
      expect(JSON.parse(response.body)["message"]).to eq("ポイントが不足しています")
    end

    it "buy to other user buy item" do
      Item.buy(@target_item, @user3) 
      post "/api/v1/items/#{@target_item.id}/buy", headers: @headers
      expect(response.code).to eq("400")
      expect(JSON.parse(response.body)["message"]).to eq("この商品は購入できません")
    end

    it "buy unknwon item" do
      post "/api/v1/items/99999/buy", headers: @headers
      expect(response.code).to eq("404")
    end

  end

  describe "search items" do
    before do
      @other_users = FactoryBot.create_list(:other_users, 2)
      @owner_items = FactoryBot.build_list(:items, 10)
      @other_items1 = FactoryBot.build_list(:items, 20)
      @other_items2 = FactoryBot.build_list(:items, 10)
      @owner_items.each{|item| item.create_user_id = @user.id; item.save}
      @other_items1.each{|item| item.create_user_id = @other_users.first.id; item.save}
      @other_items2.each{|item| item.create_user_id = @other_users.last.id; item.save}

      @default_search_items = @owner_items.map{|item| item.attributes}
      @default_search_items.concat(@other_items1.map{|item| item.attributes})
      @default_search_items.each{|item| item["created_at"] = item["created_at"].strftime("%Y-%m-%dT%H:%M:%S.%3NZ"); item["updated_at"] = item["updated_at"].strftime("%Y-%m-%dT%H:%M:%S.%3NZ")}
      @defautl_serach_paging_items = @other_items2.map{|item| item.attributes}
      @defautl_serach_paging_items.each{|item| item["created_at"] = item["created_at"].strftime("%Y-%m-%dT%H:%M:%S.%3NZ"); item["updated_at"] = item["updated_at"].strftime("%Y-%m-%dT%H:%M:%S.%3NZ")}
      @sign_in_search_items = @other_items1.map{|item| item.attributes}
      @sign_in_search_items.concat(@other_items2.map{|item| item.attributes})
      @sign_in_search_items.each{|item| item["created_at"] = item["created_at"].strftime("%Y-%m-%dT%H:%M:%S.%3NZ"); item["updated_at"] = item["updated_at"].strftime("%Y-%m-%dT%H:%M:%S.%3NZ")}
    end

    it "default search" do
      get "/api/v1/items/search"
      expect(response.code).to eq("200")
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("SUCCESS")
      expect(body["data"].length).to eq(30)
      expect(body["data"]).to match_array(@default_search_items)
    end

    it "default search paging" do
      param = {page: 2}
      get "/api/v1/items/search", params: param
      expect(response.code).to eq("200")
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("SUCCESS")
      expect(body["data"].length).to eq(10)
      expect(body["data"]).to match_array(@defautl_serach_paging_items)
    end

    it "sign in search" do
      get "/api/v1/items/search", headers: @headers
      expect(response.code).to eq("200")
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq(30)
      expect(body["data"]).to match_array(@sign_in_search_items)
    end
  end

end
