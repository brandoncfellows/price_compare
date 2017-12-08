class Product < ActiveRecord::Base
  
  validates :upc, :presence=>true
  
  has_many :prices
  has_many :bookmarks
end
