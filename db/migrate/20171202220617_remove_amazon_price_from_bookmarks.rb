class RemoveAmazonPriceFromBookmarks < ActiveRecord::Migration
  def change
    remove_column :bookmarks, :amazon_price, :integer
  end
end
