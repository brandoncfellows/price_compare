class AddImageToProducts < ActiveRecord::Migration
  def change
    remove_column :products, :url
    add_column :products, :image, :string
  end
end
