require 'open-uri'

class WalmartController < ApplicationController

def search

render("walmart/lookup.html.erb")

end


def view

upc = params[:id]

url="http://api.walmartlabs.com/v1/search?apiKey=5mgg97myhj4gms5g7dtnhw4m&query=#{upc}"
@data = JSON.parse(open(url).read)

render("walmart/view.html.erb")

end

end
