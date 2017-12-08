class AddUrlToProducts < ActiveRecord::Migration
  def change
    add_column :products, :amazon_url, :string
    add_column :products, :walmart_url, :string
  end
end
