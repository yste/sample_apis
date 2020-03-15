class Item < ApplicationRecord
  belongs_to :create_user, class_name: User, foreign_key: :create_user_id
  belongs_to :buy_user, class_name: User, foreign_key: :buy_user_id, optional: true
  has_one :transaction_history

  before_destroy :check_item
  after_save :create_transaction_history

  class PointLackError < StandardError; end
  class MyItemBuyError < StandardError; end
  class ExhibitError < StandardError; end

  # 購入処理
  def self.buy(buy_item, buy_user)
    buy_item.reload
    # 自分の商品は買うことが出来ない
    raise MyItemBuyError.new("自身が登録した商品は購入できません") if buy_item.create_user_id == buy_user.id
    # 未出品の商品は買うことが出来ない
    raise ExhibitError.new("この商品は購入できません") unless buy_item.exhibit_flag
    # ポイント残高不足
    raise PointLackError.new("ポイントが不足しています") if buy_user.point < buy_item.point
    sell_user = buy_item.create_user
    ActiveRecord::Base.transaction do
      buy_item.buy_user_id = buy_user.id
      buy_item.exhibit_flag = false
      buy_user.point -= buy_item.point
      sell_user.point += buy_item.point

      buy_item.save!
      buy_user.save!
      sell_user.save!
    end
  end

  private
  def create_transaction_history
    return if self.buy_user_id.blank?
    self.create_transaction_history!(buy_user_id: self.buy_user_id, sell_user_id: self.create_user_id, point: self.point)
  end

  def check_item
    if self.buy_user_id.present?
      errors.add(:all, message: "売却した商品は削除できません")
    end
    if self.exhibit_flag
      errors.add(:alll, message: "出品中の商品は削除できません")
    end
  end

end
