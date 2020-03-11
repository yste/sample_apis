class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :point
      t.integer :user_id

      t.timestamps
    end
  end
end
