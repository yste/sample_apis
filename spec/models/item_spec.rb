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
    expect(item.transaction_history).to have_attributes(item_id: item.id, buy_user_id: @buy_user.id, sell_user_id: @user.id, point: item.point) 
    expect(@user.sell_histories.first).to have_attributes(item_id: item.id)
    expect(@buy_user.buy_histories.first).to have_attributes(item_id: item.id)
  end

  it "buy no exhibit item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: false))
    expect{Item.buy(item, @buy_user)}.to raise_error(Item::ExhibitError)

  end
  
  it "buy owner item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: true))
    expect{Item.buy(item, @user)}.to raise_error(Item::MyItemBuyError)
  end

  it "destroy item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: false))
    expect(item.destroy).to be_truthy 
  end

  it "destroy on exhibit item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: true))
    item.destroy
    expect(item.errors).to_not be_empty
    expect(item.errors.messages[:all][0]).to eq("出品中の商品は削除できません")
  end

  it "destroy on buy item" do
    item = Item.create(FactoryBot.attributes_for(:item1).merge(create_user_id: @user.id, exhibit_flag: true))
    Item.buy(item, @buy_user)
    item.destroy
    expect(item.errors).to_not be_empty
    expect(item.errors.messages[:all][0]).to eq("売却した商品は削除できません")
  end
end
