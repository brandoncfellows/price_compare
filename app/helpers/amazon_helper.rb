module AmazonHelper

  def self.info(query)
     
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
    "ItemId" => query,
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

   
    data = Hash.from_xml(open(request_url).read)
    hash={} 
    array=[]

    if data["ItemLookupResponse"]["Items"]["Request"].key?("Errors")
      hash[:amazon_price]="Not Available"
      hash[:url]= "Not Available"
      hash[:title]= "Not Available"
    
    else
     
      #get price
     
      if data["ItemLookupResponse"]["Items"]["Item"].is_a?(Array)  
        data["ItemLookupResponse"]["Items"]["Item"].each do |item|
          if item["OfferSummary"]["TotalNew"].to_i >0
            array.push(item["OfferSummary"]["LowestNewPrice"]["Amount"].to_f)
          else  
            if item["ItemAttributes"]["ListPrice"].is_a?(Hash)
              array.push(item["ItemAttributes"]["ListPrice"]["Amount"].to_f)
            else
              array.push()
            end
          end 
        end
        best = array.each_with_index.min
        hash[:amazon_price] = best[0]/100
      else
        if data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["TotalNew"].to_i > 0
          hash[:amazon_price] = data["ItemLookupResponse"]["Items"]["Item"]["OfferSummary"]["LowestNewPrice"]["Amount"].to_f/100
        else 
          if data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"].is_a?(Hash)
            hash[:amazon_price] = data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ListPrice"]["Amount"].to_f/100
          else
            hash[:amazon_price] = "Not Available"
          end
        end
      end
        
      #get url
     
      if data["ItemLookupResponse"]["Items"]["Item"].is_a?(Array)
        hash[:url]=data["ItemLookupResponse"]["Items"]["Item"][best[1]]["DetailPageURL"]
      else
        hash[:url]=data["ItemLookupResponse"]["Items"]["Item"]["DetailPageURL"]
      end
      
      #get title
      if data["ItemLookupResponse"]["Items"]["Item"].is_a?(Array)
        hash[:title]=data["ItemLookupResponse"]["Items"]["Item"][best[1]]["ItemAttributes"]["Title"]
      else
        hash[:title]=data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Title"]
      end
    
    end
  return hash
  end      
end