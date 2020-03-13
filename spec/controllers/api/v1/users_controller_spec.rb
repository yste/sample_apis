require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe "create user" do

    it "create user success" do
      params = FactoryBot.attributes_for(:base_user_params)
      post "/api/v1/auth", params
      expect(response.code).to eq("200")
    end

    it "create user error. empty password" do
      params = FactoryBot.attributes_for(:empty_pass_user_params)
      post "/api/v1/auth", params
      expect(response.code).to eq("422")
    end

    it "create user error. unmatch password" do
      params = FactoryBot.attributes_for(:unmatch_pass_user_params)
      post "/api/v1/auth", params
      expect(response.code).to eq("422")
    end

    it "create user error. known email" do
      FactoryBot.create(:base_user)
      params = FactoryBot.attributes_for(:known_user_params)
      post "/api/v1/auth", params
      expect(response.code).to eq("422")
    end

  end

  describe "sign in user" do
    before do
      FactoryBot.create(:base_user)
    end

    it "sing in success" do
      params = FactoryBot.attributes_for(:base_user)
      post "/api/v1/auth/sign_in", params
      expect(response.code).to eq("200")
    end

  end


  describe "sing out user" do
    before do
      FactoryBot.create(:base_user)
      params = FactoryBot.attributes_for(:base_user)
      post "/api/v1/auth/sign_in", params
      @headers = {'Content-Type' => 'application/json',
                  'access-token' => response.header["access-token"],
                  'client' => response.header["client"],
                  'uid' => response.header["uid"]
      }
    end

    it "sign out user" do
      delete "/api/v1/auth/sign_out", headers: @headers
      expect(response.code).to eq("200")
    end

  end

end
