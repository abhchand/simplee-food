require_relative 'auth_controller'

get '/' do
  redirect '/recipes'
end
