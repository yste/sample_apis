class CreateTransactionHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :transaction_histories do |t|
      t.integer :item_id
      t.integer :buy_user_id
      t.integer :sell_user_id
      t.integer :point

      t.timestamps
    end
  end
end
