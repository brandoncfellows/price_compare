class AddNameColumnToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :name, :string
  end
end
