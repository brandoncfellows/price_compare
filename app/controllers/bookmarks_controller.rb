class BookmarksController < ApplicationController
  
  def index

  @bookmarks=Bookmark.all
  
    render("bookmarks/index.html.erb")
  end

  def show
    @bookmark = Bookmark.find(params[:id])
 
    walmart=[]
    i=0
    @bookmark.product.prices.each do |price|
      walmart[i]=[price.created_at.strftime("%I:%M%p %D"), price.walmart]
      i=i+1
    end 
    
    amazon=[]
    i=0
    @bookmark.product.prices.each do |price|
      amazon[i]=[price.created_at.strftime("%I:%M%p %D"), price.amazon]
      i=i+1
    end 
    
    @discount=(@bookmark.product.prices.last.amazon-@bookmark.product.prices.last.walmart)/@bookmark.product.prices.last.amazon*100
    
    @chart = [{:name => "Walmart", :data => walmart},{:name => "Amazon", :data =>amazon}]
 
 
    render("bookmarks/show.html.erb")
  end

  def new
    @bookmark = Bookmark.new

    render("bookmarks/new.html.erb")
  end

  def create
    @bookmark = Bookmark.new

    @bookmark.user_id = params[:user_id]
    
    if Product.where(:upc=>params[:upc])!=[]
      @bookmark.product_id=Product.where(:upc=>params[:upc]).first.id
      @bookmark.save
    else
      @product=Product.new
      @product.upc = params[:upc]
      @product.image = params[:image]
      @product.name = params[:name]
      @product.amazon_url = params[:amazon_url]
      @product.walmart_url = params[:url]
      @product.save
    
      @bookmark.product_id = @product.id
      @bookmark.save
    
      @price=Price.new
      @price.amazon = params[:amazon_price]
      @price.walmart = params[:price]
      @price.product_id = @product.id
      @price.save
    end 
    if @bookmark.save
      redirect_to("/bookmarks", :notice => "Successfully added to watch list.")
    else 
      redirect_to(:back, :alert => "Not added. No UPC number available")
    end
    
  end

  def cart
    @bookmark = Bookmark.all

    render("bookmarks/cart.html.erb")
  end
  
  def add
    @bookmark = Bookmark.find(params[:id])
    @bookmark.cart=1
    @bookmark.save
    redirect_to("/cart", :notice => "Successfully added to cart.")
  end

  def delete
    @bookmark = Bookmark.find(params[:id])
    @bookmark.cart=nil
    @bookmark.save
    redirect_to(:back)
  end 

  def update
    @price = Price.new
    @price.product_id = params[:id]
    @price.amazon = AmazonHelper.info(Product.find(params[:id]).upc)[:price]
    @price.walmart = WalmartHelper.info(Product.find(params[:id]).upc)[:price]

    @price.save

    redirect_to(:back)
    
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])

    @bookmark.destroy


    redirect_to("/bookmarks")

  end
end
