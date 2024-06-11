get '/', auth: :user do
  redirect '/recipes'
end
