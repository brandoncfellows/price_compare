class Bookmark < ActiveRecord::Base
    
    validates :user_id, :presence=>true
    validates :product_id, :presence=>true
    
    belongs_to :user
    belongs_to :product
    
end
