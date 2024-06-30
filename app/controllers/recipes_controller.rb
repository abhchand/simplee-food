get '/recipes', auth: :user do
  response = RecipeSearchService.new(params).call

  @recipes = response['items']
  @sort_by = 'created_at'
  @tag = response['tag']
  @pagination = {
    first_item: response['first_item'],
    last_item: response['last_item'],
    total_items: response['total_items'],
    current_page: response['current_page'],
    last_page: response['last_page']
  }

  erb :'recipes/index'
end

get '/recipes/new', auth: :user do
  @recipe = Recipe.new
  @tags = Tag.all.order(:name)

  erb :'recipes/edit'
end

get '/recipes/:slug', auth: :user do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  return(status 404) unless @recipe

  erb :'recipes/show'
end

get '/recipes/:slug/edit', auth: :user do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  @tags = Tag.all.order(:name)

  return(status 404) unless @recipe

  erb :'recipes/edit'
end

delete '/recipes/:slug', auth: :user do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  return(status 404) unless @recipe

  @recipe.destroy! if @recipe

  redirect '/recipes'
end
