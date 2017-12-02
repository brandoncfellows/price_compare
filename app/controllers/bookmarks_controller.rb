class BookmarksController < ApplicationController
  def index

  @bookmarks=current_user.bookmarks
=begin    
    walmart_array=[]
    current_user.bookmarks.pluck(:upc).each do |upc|
      walmart_array.push(WalmartHelper.info(upc))
    end
    
    walmart_array.each do |item|
    amazon=AmazonHelper.info(item[:upc])
    item[:amazon_price]=amazon[:price]
    item[:amazon_url]=amazon[:url]
    if item[:amazon_price].class==String 
      item[:discount]=0
    else
      item[:discount]=(item[:amazon_price]-item[:price])/item[:amazon_price]*100
    end 
  end
=end


    render("bookmarks/index.html.erb")
  end

  def show
    @bookmark = Bookmark.find(params[:id])

    render("bookmarks/show.html.erb")
  end

  def new
    @bookmark = Bookmark.new

    render("bookmarks/new.html.erb")
  end

  def create
    @bookmark = Bookmark.new

    @bookmark.user_id = params[:user_id]
    @bookmark.upc = params[:upc]
    @bookmark.image = params[:image]
    @bookmark.name = params[:name]
    @bookmark.amazon_price = params[:amazon_price]
    @bookmark.walmart_price = params[:walmart_price]
    @bookmark.add_to_cart = params[:add_to_cart]

    save_status = @bookmark.save

    if save_status == true
      redirect_to("/bookmarks", :notice => "Bookmark created successfully.")
    else
      render("bookmarks/index.html.erb")
    end
  end

  def edit
    @bookmark = Bookmark.find(params[:id])

    render("bookmarks/edit.html.erb")
  end

  def update
    @bookmark = Bookmark.find(params[:id])

    @bookmark.user_id = params[:user_id]
    @bookmark.upc = params[:upc]

    save_status = @bookmark.save

    if save_status == true
      redirect_to("/bookmarks/#{@bookmark.id}", :notice => "Bookmark updated successfully.")
    else
      render("bookmarks/edit.html.erb")
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])

    @bookmark.destroy


    redirect_to("/bookmarks", :notice => "Bookmark deleted.")

  end
end
