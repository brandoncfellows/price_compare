class CompareController < ApplicationController

def search
render("compare/lookup.html.erb")
end

def view

  query = params[:id]
  walmart_array = WalmartHelper.search(query)

  walmart_array.each do |item|
    amazon=AmazonHelper.info(item[:upc])
    item[:amazon_price]=amazon[:price]
    item[:amazon_url]=amazon[:url]
    if item[:amazon_price].class==String 
      item[:discount]=-1000
    else
      item[:discount]=(item[:amazon_price]-item[:price])/item[:amazon_price]*100
    end 
  end
  @walmart_array=walmart_array.sort_by { |v| v[:discount] }.reverse
  @walmart_array.each do |item|
    if item[:discount]==-1000
      item[:discount]="N/A"
    end
  end
  render("compare/view.html.erb")
end



def list 

@id=params[:id]

if @id==nil
  @id=1
end

walmart_array = WalmartHelper.clearance(@id)

  walmart_array.each do |item|
    amazon=AmazonHelper.info(item[:upc])
    item[:amazon_price]=amazon[:price]
    item[:amazon_url]=amazon[:url]
    if item[:amazon_price].class==String 
      item[:discount]= -1000
    else
      item[:discount]=(item[:amazon_price]-item[:price])/item[:amazon_price]*100
    end 
  end
  @array3=walmart_array.sort_by { |v| v[:discount] }.reverse
  @array3.each do |item|
    if item[:discount]==-1000
      item[:discount]="N/A"
    end
  end

render("compare/list.html.erb")
end


end