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

  it "show my items" do
    get "/api/v1/items", headers: @headers
    expect(response.code).to eq("200")
  end

  it "create items" do
    post "/api/v1/items", params: FactoryBot.attributes_for(:item1), headers: @headers
    expect(response.code).to eq("200")
  end

  describe "edit items" do
    it "owner item edit" do
    end

    it "other user item edit" do
    end
  end

  describe "delete items" do
    it "owner item delete" do
    end

    it "other user item delete" do
    end
  end

  describe "buy items" do
    it "buy item" do
    end

    it "buy owner item" do
    end

    it "edit and buy item 1" do
    end

    it "edit and buy item 2" do
    end

    it "delete and buy item" do
    end

  end

  describe "search items" do
    it "default search" do
    end
  end

end
