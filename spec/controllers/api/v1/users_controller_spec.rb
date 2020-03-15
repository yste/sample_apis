require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
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

  it "show index" do
    get "/api/v1/users", headers: @headers
    expect(response.code).to eq("200")
  end

  it "unautholized show index" do
    get "/api/v1/users"
    expect(response.code).to eq("401")
  end
end
