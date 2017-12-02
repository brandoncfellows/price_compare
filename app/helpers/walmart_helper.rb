module WalmartHelper
    
  def self.info(query)
    api_key = "5mgg97myhj4gms5g7dtnhw4m"
    require "open-uri"
    hash={}
    
    data = JSON.parse(open("http://api.walmartlabs.com/v1/search?apiKey=#{api_key}&query=#{query}").read)
    
    if data["message"]=="Results not found!"
      hash[:walmart_price]= "Not Available"
      hash[:image]= "Not Available"
      hash[:url]= "Not Available"
      hash[:add_to_cart] = "Not Available"
      hash[:upc] = "Not Avaialble"
      hash[:name] = "Not Available"
    
    else
      hash[:walmart_price]= data["items"][0]["salePrice"].to_f
      hash[:image]= data["items"][0]["largeImage"]
      hash[:url]= data["items"][0]["productUrl"]
      hash[:add_to_cart] = data["items"][0]["addToCartUrl"]
      hash[:upc] = data["items"][0]["upc"]
      hash[:name] = data["items"][0]["name"]
    end  
    return hash
  end

  def self.search(query)
    api_key = "5mgg97myhj4gms5g7dtnhw4m"
    require "open-uri"
    array=[]
    i=0
    
    data = JSON.parse(open("http://api.walmartlabs.com/v1/search?apiKey=#{api_key}&query=#{query}").read)
    data["items"].each do |item|
      array.push({})
      array[i][:walmart_price]= item["salePrice"].to_f
      array[i][:image]= item["largeImage"]
      array[i][:url]= item["productUrl"]
      array[i][:add_to_cart] = item["addToCartUrl"]
      array[i][:upc] = item["upc"]
      array[i][:name] = item["name"]
      i=i+1
    end
    return array
  end

#pull clearance items

  def self.clearance(i)
    require "open-uri"
    array=[]
  
    a=open("https://www.walmart.com/browse/0/0?cat_id=0&facet=special_offers%3AClearance&page=#{i}#searchProductResult").read
    b=a.split("\"upc\":\"")
    b.shift
    b.each do |var|
      c=var.split("\"")[0]
      array.push(c)
    end
    array2=[]
    array[0..9].each do |upc|
      array2.push(WalmartHelper.info(upc))
    end

  return array2
  end 
end 