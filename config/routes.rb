Rails.application.routes.draw do

  # Routes for the Bookmark resource:
  # CREATE
  get "/bookmarks/new", :controller => "bookmarks", :action => "new"
  post "/create_bookmark", :controller => "bookmarks", :action => "create"

  # READ
  get "/bookmarks", :controller => "bookmarks", :action => "index"
  get "/bookmarks/:id", :controller => "bookmarks", :action => "show"

  # UPDATE
  get "/delete", :controller => "bookmarks", :action => "delete"
  get "/add", :controller => "bookmarks", :action => "add"
  get "/cart", :controller => "bookmarks", :action => "cart"
  get "/update_price", :controller => "bookmarks", :action => "update"

  # DELETE
  get "/delete_bookmark/:id", :controller => "bookmarks", :action => "destroy"
  #------------------------------

  devise_for :users

get "/walmart", :controller => "walmart", :action => "view"
get "/search", :controller => "walmart", :action => "search"

get "/amazon/:id", :controller => "amazon", :action => "view"
get "/asearch", :controller => "amazon", :action => "search"

get "/compare", :controller => "compare", :action => "view"
get "/find", :controller => "compare", :action => "search"
get "/list/:id", :controller => "compare", :action =>"list"

root "compare#list"

end
