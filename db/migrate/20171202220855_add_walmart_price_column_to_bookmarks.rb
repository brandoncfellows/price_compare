class AddWalmartPriceColumnToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :walmart_price, :float
  end
end
