require_relative 'auth_controller'

get '/settings', authenticate: :always do
  @page_title = 'Settings'
  erb :'settings/index'
end
