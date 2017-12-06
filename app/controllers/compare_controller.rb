class CompareController < ApplicationController

def search
render("compare/lookup.html.erb")
end

def view

  query = params[:id]
  walmart_array = WalmartHelper.search(query)

  walmart_array.each do |item|
    amazon=AmazonHelper.info(item[:upc])
    item[:amazon_price]=amazon[:amazon_price]
    item[:amazon_url]=amazon[:url]
    if item[:amazon_price].class==String 
      item[:discount]=-1000
    else
      item[:discount]=(item[:amazon_price]-item[:walmart_price])/item[:amazon_price]*100
    end 
  end
  @walmart_array=walmart_array.sort_by { |v| v[:discount] }.reverse
  @walmart_array.each do |item|
    if item[:discount]==-1000
      item[:discount]="Not Available"
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
    item[:amazon_price]=amazon[:amazon_price]
    item[:amazon_url]=amazon[:url]
    if item[:amazon_price].class==String 
      item[:discount]= -1000
    else
      item[:discount]=(item[:amazon_price]-item[:walmart_price])/item[:amazon_price]*100
    end 
  end
  @array3=walmart_array.sort_by { |v| v[:discount] }.reverse
  @array3.each do |item|
    if item[:discount]==-1000
      item[:discount]="Not Available"
    end
  end

=begin

require "open-uri"  

search=params[:id]

api_key = "5mgg97myhj4gms5g7dtnhw4m"

if search.class!=String
  page=rand(1..25)

  a=open("https://www.walmart.com/browse/0/0?cat_id=0&facet=special_offers%3AClearance&page=#{page}#searchProductResult").read
else
  page= 1
  a=open("https://www.walmart.com/search/?cat_id=0&page=#{page}&query=#{search}#searchProductResult").read
  #  a=open("http://api.walmartlabs.com/v1/search?apiKey=#{api_key}&query=#{search}"
end 

b=a.split("\"upc\":\"")

array=[]

b.each do |var|
  c=var.split("\"")
  array.push(c[0])
end

start = 1

if search.class!=String
  start = rand(1..(array.count-15))
end 

finish = start+15
array = array[start..finish]

array2=[]
price_array=[]

i=0

array.each do |num|
  url="http://api.walmartlabs.com/v1/search?apiKey=#{api_key}&query=#{num}"
  data = JSON.parse(open(url).read)
  if data["items"].is_a?(Array)
    if data["items"][0].key?("upc")
      array2.push({})
 
      #get UPC number
      array2[i][:upc] = data["items"][0]["upc"]

      #get walmart price
      if data["numItems"] > 1
        data["items"].each do |item|
          price_array.push(item["salePrice"].to_f)
        end
        best = price_array.each_with_index.min
        array2[i][:walmart_price]=best[0].to_f
        array2[i][:image]= data["items"][best[0]]["largeImage"]
#        array2[i][:walmart_url]=
      else
        array2[i][:walmart_price]= data["items"][0]["salePrice"].to_f
        array2[i][:image]= data["items"][0]["largeImage"]
      end
      #get amazon information
      require 'time'
      require 'uri'
      require 'openssl'
      require 'base64'
      require 'open-uri'
      require 'nokogiri'
      require 'ostruct'

      # Your Secret Key corresponding to the above ID, as taken from the Your Account page
      secret_key = "VpEXPC+cd1zQ5jHd+yragEXeI9K2v5AFTCO/MTnD"

      # The region you are interested in
      endpoint = "webservices.amazon.com"

      request_uri = "/onca/xml"

      params = {
        "Service" => "AWSECommerceService",
        "Operation" => "ItemLookup",
        "AWSAccessKeyId" => "AKIAIMHAOMM6TBWMUYKA",
        "AssociateTag" => "brandoncfello-20",
        "ItemId" => array2[i][:upc],
        "IdType" => "UPC",
        "ResponseGroup" => "Images,ItemAttributes,Offers",
        "SearchIndex" => "All"
      }

      # Set current timestamp if not set
      params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")

      # Generate the canonical query
      canonical_query_string = params.sort.collect do |key, value|
        [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
      end.join('&')

      # Generate the string to be signed
      string_to_sign = "GET\n#{endpoint}\n#{request_uri}\n#{canonical_query_string}"

      # Generate the signature required by the Product Advertising API
      signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret_key, string_to_sign)).strip()

      # Generate the signed URL
      request_url = "http://#{endpoint}#{request_uri}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

      xml = open(request_url).read 
      amazon_data = Hash.from_xml(xml)

      if amazon_data["ItemLookupResponse"]["Items"]["Request"].key?("Errors")
        array2.delete_at(i)
        i=i-1
      else

        amazon_price_array=[]  

        if amazon_data["ItemLookupResponse"]["Items"]["Item"].is_a?(Array)
          amazon_data["ItemLookupResponse"]["Items"]["Item"].each do |item|
            if item["OfferSummary"]["TotalNew"].to_i >0
              amazon_price_array.push(item["OfferSummary"]["LowestNewPrice"]["Amount"].to_f)
            else
              if item["ItemAttributes"]["ListPrice"].is_a?(Hash)
                amazon_price_array.push(item["ItemAttributes"]["ListPrice"]["Amount"].to_f)
              end
            end 
          end
          amazon_best = amazon_price_array.each_with_index.min
          array2[i][:title] = amazon_data["ItemLookupResponse"]["Items"]["Item"][amazon_best[1]]["ItemAttributes"]["Title"]
          array2[i][:amazon_price] = amazon_best[0]/100
        else
          array2[i][:title] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Title"]
          if amazon_data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["TotalNew"].to_i > 0
              array2[i][:amazon_price] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["LowestNewPrice"]["Amount"].to_f/100
          else 
            if amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"].is_a?(Hash)
              array2[i][:amazon_price] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"]["Amount"].to_f/100
            else
              array2.delete_at(i)
              i=i-1
            end 
          end
        end
      end
      i=i+1
      break if i==5
    end
  end
end  

array2.each do |margin|
  if margin[:amazon_price].class==String || margin[:walmart_price].class==String
    margin[:discount]=0
  else
    margin[:discount]=(((margin[:amazon_price]-margin[:walmart_price])/margin[:amazon_price])*100).round(1)
  end
end

@array2=array2

@array3 = @array2.sort_by { |v| v[:discount] }.reverse
=end

render("compare/list.html.erb")
end


end