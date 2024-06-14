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

get '/recipes/:slug' do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)

  erb :'recipes/show'
end

delete '/recipes/:slug' do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  @recipe.destroy! if @recipe

  redirect '/recipes'
end
