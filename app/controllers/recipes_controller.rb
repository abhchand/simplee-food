require_relative 'auth_controller'

get '/recipes', authenticate: :conditionally do
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

  @page_title = 'Recipes'
  erb :'recipes/index'
end

get '/recipes/new', authenticate: :always do
  @recipe = Recipe.new
  @tags = Tag.all.order(:name)

  @page_title = 'New Recipe'
  erb :'recipes/edit'
end

get '/recipes/:slug', authenticate: :conditionally do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  return(status 404) unless @recipe

  @page_title = truncate_str(@recipe.name)
  erb :'recipes/show'
end

get '/recipes/:slug/edit', authenticate: :always do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  @tags = Tag.all.order(:name)

  return(status 404) unless @recipe

  @page_title = truncate_str("Edit #{@recipe.name}")
  erb :'recipes/edit'
end
