class ChangeUpcToString < ActiveRecord::Migration
  def change
    change_column :products, :upc, :string
  end
end
