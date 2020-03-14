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
    expect(item.exhibit_flag).to eq(false)
  end

  it "buy item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: true))
    Item.buy(item, @buy_user)
    @user.reload
    @buy_user.reload
    item.reload
    expect(item.buy_user_id).to eq(@buy_user.id)
    expect(item.exhibit_flag).to eq(false)
    expect(@user.point).to eq(item.point + 1000)
    expect(@buy_user.point).to eq(1000 - item.point)
  end

  it "buy no exhibit item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: false))
    expect{Item.buy(item, @buy_user)}.to raise_error(Item::ExhibitError)

  end

end
