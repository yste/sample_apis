require 'rails_helper'

RSpec.describe User, type: :model do
  it "ユーザー新規作成時に1000ポイント付与されている事" do
    user = FactoryBot.create(:base_user)
    expect(user.point).to eq(1000)
  end

  it "email validation error" do
    user = User.new(FactoryBot.attributes_for(:email_error_user))
    expect(user.valid?).to eq(false)
  end

  it "email uniqueness error" do
    user = FactoryBot.create(:base_user)
    valid_user = User.new(FactoryBot.attributes_for(:known_user_params))
    expect(valid_user.valid?).to eq(false)
  end
end
