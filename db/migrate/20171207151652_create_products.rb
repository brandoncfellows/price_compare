class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.float :upc
      t.string :url

      t.timestamps null: false
    end
  end
end
