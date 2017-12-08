class Price < ActiveRecord::Base
  
  validates :amazon, :presence=>true
  validates :walmart, :presence=>true
  
  belongs_to :product
end
