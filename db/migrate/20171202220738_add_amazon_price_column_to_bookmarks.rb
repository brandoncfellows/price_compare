class AddAmazonPriceColumnToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :amazon_price, :float
  end
end
