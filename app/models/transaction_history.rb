class TransactionHistory < ApplicationRecord
  belongs_to :item
  belongs_to :buy_user, class_name: User, foreign_key: :buy_user_id
  belongs_to :sell_user, class_name: User, foreign_key: :sell_user_id
end
