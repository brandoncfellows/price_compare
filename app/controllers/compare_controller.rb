class CompareController < ApplicationController

def search
render("compare/lookup.html.erb")
end

def view

upc = params[:id]

require 'time'
require 'uri'
require 'openssl'
require 'base64'
require 'open-uri'
require 'httparty'
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
  "ItemId" => upc,
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
data = Hash.from_xml(xml)



if data["ItemLookupResponse"]["Items"]["Request"].key?("Errors")
  @image = "Item Not Available on Amazon"
  @title = "Item Not Available on Amazon"
  @amazon_price = "Item Not Available on Amazon"

else

amazon_price_array=[]  

if data["ItemLookupResponse"]["Items"]["Item"].is_a?(Array)
  data["ItemLookupResponse"]["Items"]["Item"].each do |item|
    if item["ItemAttributes"]["ListPrice"].is_a?(Hash)
      amazon_price_array.push(item["ItemAttributes"]["ListPrice"]["Amount"].to_f)
    else
     amazon_price_array.push(item["OfferSummary"]["LowestNewPrice"]["Amount"].to_f)  
    end 
  end

amazon_array_num = amazon_price_array.each_with_index.min[1]
@image = data["ItemLookupResponse"]["Items"]["Item"][amazon_array_num]["LargeImage"]["URL"]
@title = data["ItemLookupResponse"]["Items"]["Item"][amazon_array_num]["ItemAttributes"]["Title"]
@amazon_price = "$" + (data["ItemLookupResponse"]["Items"]["Item"][amazon_array_num]["ItemAttributes"]["ListPrice"]["Amount"].to_f/100).to_s

else
  

  @image = data["ItemLookupResponse"]["Items"]["Item"]["LargeImage"]["URL"]
  @title = data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Title"]
if data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"].is_a?(Hash)
  @amazon_price = "$" + (data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"]["Amount"].to_f/100).to_s
else
  @amazon_price = "$" + (data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["LowestNewPrice"]["Amount"].to_f/100).to_s
end
end
end


url="http://api.walmartlabs.com/v1/search?apiKey=5mgg97myhj4gms5g7dtnhw4m&query=#{upc}"
wal_data = JSON.parse(open(url).read)

if wal_data["message"] == "Results not found!"
  @walmart_price = "Item Not Available at Walmart"

else 
wal_many = wal_data["items"][0]

price_array=[]

if wal_many
JSON.parse(open(url).read)["items"].each do |item|
price_array.push(item["salePrice"])
end

array_num = price_array.each_with_index.min[1]

@walmart_price = "$"+JSON.parse(open(url).read)["items"][array_num]["salePrice"].to_s
else
@walmart_price = "$"+JSON.parse(open(url).read)["items"]["salePrice"].to_s  
end

end

@upc=upc

@difference = sprintf("$%2.2f", @amazon_price.gsub("$","").to_f - @walmart_price.gsub("$","").to_f)

@fees = sprintf("$%2.2f", @amazon_price.gsub("$","").to_f * 0.15)

render("compare/view.html.erb")
end



def list 

require "open-uri"  
page= rand(1..25)
a=open("https://www.walmart.com/browse/0/0?cat_id=0&facet=special_offers%3AClearance&page=#{page}#searchProductResult").read
b=a.split("\"upc\":\"")

array=[]

b.each do |var|
  c=var.split("\"")
  array.push(c[0])
end
start = rand(1..(array.count-20))
finish = start+20
array = array[start..finish]

array2=[]
price_array=[]

i=0

array.each do |num|
  url="http://api.walmartlabs.com/v1/search?apiKey=5mgg97myhj4gms5g7dtnhw4m&query=#{num}"
  data = JSON.parse(open(url).read)
  if data["items"].is_a?(Array)
    if data["items"][0].key?("upc")
      array2.push({})
 
      #get UPC number
      array2[i][:upc] = data["items"][0]["upc"]

      #get walmart price
      if data["items"].count > 1
        data["items"].each do |item|
          price_array.push(item["salePrice"].to_f)
        end
        best = price_array.each_with_index.min
        array2[i][:walmart_price]=best[0].to_f
        array2[i][:image]= data["items"][best[0]]["largeImage"]
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
      require 'httparty'
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
            if item["ItemAttributes"]["ListPrice"].is_a?(Hash)
              amazon_price_array.push(item["ItemAttributes"]["ListPrice"]["Amount"].to_f)
            else
              if item["OfferSummary"]["TotalNew"].to_i >0
                amazon_price_array.push(item["OfferSummary"]["LowestNewPrice"]["Amount"].to_f)
              end
            end 
          end
          amazon_best = amazon_price_array.each_with_index.min
          array2[i][:title] = amazon_data["ItemLookupResponse"]["Items"]["Item"][amazon_best[1]]["ItemAttributes"]["Title"]
          array2[i][:amazon_price] = amazon_best[0]/100
        else
          array2[i][:title] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Title"]
          if amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"].is_a?(Hash)
            array2[i][:amazon_price] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"]["Amount"].to_f/100
          else 
            if amazon_data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["TotalNew"].to_i > 0
              array2[i][:amazon_price] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["LowestNewPrice"]["Amount"].to_f/100
            else
              array2.delete_at(i)
              i=i-1
            end 
          end
        end
      end
      i=i+1
      break if i==10
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
 
render("compare/list.html.erb")
end


end