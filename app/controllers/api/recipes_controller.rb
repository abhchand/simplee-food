require_relative '../auth_controller'

get '/api/recipes', authenticate: :conditionally do
  content_type :json

  begin
    response = RecipeSearchService.new(params).call
  rescue => e
    status 500
    { error: "an error occurred: #{e.message}" }.to_json
    return
  end

  locals = {
    recipes: response['items'],
    sort_by: params['sort_by'],
    tag: response['tag'],
    pagination: {
      first_item: response['first_item'],
      last_item: response['last_item'],
      total_items: response['total_items'],
      current_page: response['current_page'],
      last_page: response['last_page']
    }
  }
  options = { layout: false }
  html = erb(:'recipes/recipe-item', options, locals)

  status 200
  { html: html }.to_json
end

put '/api/recipes', authenticate: :always do
  @recipe = Recipe.new

  begin
    RecipeUpdateService.new(@recipe, params).call
  rescue RecipeUpdateService::UpdateError => e
    status 500
    return { error: e.message }.to_json
  rescue StandardError => e
    status 500
    return { error: 'An unknown error occurred' }.to_json
  end

  # Ideally we'd `redirect()` here to send a 301 Response back to the frontend,
  # which would follow the redirect. However, it doesn't seem straightforward
  # behavior to implement that
  #
  # https://stackoverflow.com/a/39739894/2490003
  #
  # We settle for a 200 JSON reponse and let the frontend manually redirect.
  status 200
  {
    # We reload because if the `name` has changed, the slug may have changed
    url: "/recipes/#{@recipe.reload.slug}"
  }.to_json
end

put '/api/recipes/:slug', authenticate: :always do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)

  begin
    RecipeUpdateService.new(@recipe, params).call
  rescue RecipeUpdateService::UpdateError => e
    status 500
    return { error: e.message }.to_json
  rescue StandardError => e
    status 500
    return { error: 'An unknown error occurred' }.to_json
  end

  # Ideally we'd `redirect()` here to send a 301 Response back to the frontend,
  # which would follow the redirect. However, it doesn't seem straightforward
  # behavior to implement that
  #
  # https://stackoverflow.com/a/39739894/2490003
  #
  # We settle for a 200 JSON reponse and let the frontend manually redirect.
  status 200
  {
    # We reload because if the `name` has changed, the slug may have changed
    url: "/recipes/#{@recipe.reload.slug}"
  }.to_json
end

delete '/api/recipes/:slug', authenticate: :always do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  return(status 404) unless @recipe

  @recipe.destroy! if @recipe

  content_type :json
  status 200
  {}.to_json
end
