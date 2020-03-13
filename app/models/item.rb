class Item < ApplicationRecord
  belongs_to :create_user, class_name: User, foreign_key: :create_user_id
  belongs_to :buy_user, class_name: User, foreign_key: :buy_user_id
  has_one :transaction_history

  after_save :create_transaction_history

  class PointLackError < StandardError; end
  class PurchasedError < StandardError; end
  class MyItemBuyError < StandardError; end

  # 購入処理
  def buy(buy_user)
    # 自分の商品は買うことが出来ない
    raise MyItemBuyError.new("自分が登録した商品は購入できません") if self.create_user_id == buy_user.id
    # ポイント残高不足
    raise PointLackError.new("ポイントが不足しています") if buy_user.point < self.point
    # 既に購入されている
    raise PurchasedError.new("この商品は他の方に購入されました") if self.buy_user_id.present?
    sell_user = self.create_user
    ActiveRecord::Base.transaction do
      self.buy_user_id = buy_user.id
      buy_user.point -= self.point
      sell_user.point += self.point

      self.save!
      buy_user.save!
      sell_user.save!
    end
  end

  private
  def create_transaction_history
    return if self.buy_user_id.blank?
    self.create_transaction_history!(buy_user_id: self.buy_user_id, sell_user_id: self.create_user_id, point: self.point)
  end

end
