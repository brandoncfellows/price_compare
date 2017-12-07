class AddAddToCartColumnToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :add_to_cart, :string
  end
end
