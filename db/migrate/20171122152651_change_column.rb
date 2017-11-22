class ChangeColumn < ActiveRecord::Migration
  def change
    
    change_column :bookmarks, :upc, :string
    
  end
end
