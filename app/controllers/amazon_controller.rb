class AmazonController < ApplicationController

def search
render("amazon/lookup.html.erb")
end

def view

upc = params[:id]

array=[]

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
      amazon_data = Hash.from_xml(xml)

      if amazon_data["ItemLookupResponse"]["Items"]["Request"].key?("Errors")
        array[:title]="N/A"
        array[:amazon_price]="N/A"
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
          array[:title] = amazon_data["ItemLookupResponse"]["Items"]["Item"][amazon_best[1]]["ItemAttributes"]["Title"]
          array[:amazon_price] = amazon_best[0]/100
        else
          array[:title] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Title"]
          if amazon_data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["TotalNew"].to_i > 0
              array[:amazon_price] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["LowestNewPrice"]["Amount"].to_f/100
          else 
            if amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"].is_a?(Hash)
              array[:amazon_price] = amazon_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"]["Amount"].to_f/100
            else
              array[:title]="N/A"
              array[:amazon_price]="N/A"
            end 
          end
        end
      end
      
return array
      

end

end

