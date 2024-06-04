get '/api/recipes' do
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
