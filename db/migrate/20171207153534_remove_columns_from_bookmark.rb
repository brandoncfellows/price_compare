class RemoveColumnsFromBookmark < ActiveRecord::Migration
  def change
    remove_column :bookmarks, :upc
    remove_column :bookmarks, :image
    remove_column :bookmarks, :amazon_price
    remove_column :bookmarks, :walmart_price
    remove_column :bookmarks, :name
    remove_column :bookmarks, :add_to_cart
    add_column :bookmarks, :product_id, :integer
  end
end
