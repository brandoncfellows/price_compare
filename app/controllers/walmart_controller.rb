require 'open-uri'

class WalmartController < ApplicationController

def search

render("walmart/lookup.html.erb")

end


def view

@data = WalmartHelper.info(params[:id])
@data1 = AmazonHelper.info(params[:id])

render("walmart/view.html.erb")

end

end
