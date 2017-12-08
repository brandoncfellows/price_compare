class AddCartToBookmark < ActiveRecord::Migration
  def change
    add_column :bookmarks, :cart, :integer
  end
end
