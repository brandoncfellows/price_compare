Rails.application.routes.draw do

  devise_for :users

get "/walmart", :controller => "walmart", :action => "view"
get "/search", :controller => "walmart", :action => "search"

get "/amazon", :controller => "amazon", :action => "view"
get "/asearch", :controller => "amazon", :action => "search"

get "/compare", :controller => "compare", :action => "view"
get "/find", :controller => "compare", :action => "search"
get "/list", :controller => "compare", :action =>"list"


end
