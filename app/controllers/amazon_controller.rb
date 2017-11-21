class AmazonController < ApplicationController

def search
render("amazon/lookup.html.erb")
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


xml = open(request_url).read # if your xml is in the 'data.xml' file
@data = Hash.from_xml(xml)["ItemLookupResponse"]["Items"]["Item"][1]["ItemAttributes"]

=begin

require "open-uri"

a=open("https://www.walmart.com/browse/0/0?cat_id=0&facet=special_offers%3AClearance&page=1#searchProductResult").read
b=a.split("\"upc\":\"")

array=[]

b.each do |var|
  c=var.split("\"")
  array.push(c[0])
end

@array = array[1..5]

array2=[]

array.each do |num|
  url="http://api.walmartlabs.com/v1/search?apiKey=5mgg97myhj4gms5g7dtnhw4m&query=#{num}"
  data = JSON.parse(open(url).read)
  if data["items"].is_a?(Array)
  if data["items"][0].key?("upc")
  array2.push(data["items"][0]["upc"])
  end
  end
end  


@info = array2


if data["ItemLookupResponse"]["Items"]["Item"].is_a?(Array)
@image = data["ItemLookupResponse"]["Items"]["Item"][0]["LargeImage"]["URL"]
@title = data["ItemLookupResponse"]["Items"]["Item"][0]["ItemAttributes"]["Title"]
@price = data["ItemLookupResponse"]["Items"]["Item"][0]["ItemAttributes"]["ListPrice"]["Amount"]
@upc = data["ItemLookupResponse"]["Items"]["Item"][0]["ItemAttributes"]["UPC"]

else
@image = data["ItemLookupResponse"]["Items"]["Item"]["LargeImage"]["URL"]
@title = data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Title"]
@price = data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"]["FormattedPrice"]
@upc = data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["UPC"]
end
=end
render("amazon/view.html.erb")
end

end

