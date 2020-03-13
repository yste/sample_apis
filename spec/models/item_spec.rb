require 'rails_helper'

RSpec.describe Item, type: :model do
  before do
    @user = FactoryBot.create(:base_user)
    @buy_user = FactoryBot.create(:base_user2)
  end

  it "create item" do
    item = Item.new(FactoryBot.attributes_for(:item1))
    item.create_user_id = @user.id
    item.save
    expect(item.create_user_id).to eq(@user.id)
  end

  it "buy item" do
    item = Item.new(FactoryBot.attributes_for(:item1))
    item.create_user_id = @user.id
    item.save

    item.buy(@buy_user)
    @user.reload
    @buy_user.reload
    expect(item.buy_user_id).to eq(@buy_user.id)
    expect(@user.point).to eq(item.point + 1000)
    expect(@buy_user.point).to eq(1000 - item.point)
  end

end
