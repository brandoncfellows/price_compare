class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.float :walmart
      t.float :amazon
      t.integer :product_id

      t.timestamps null: false
    end
  end
end
