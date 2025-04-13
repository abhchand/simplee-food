require_relative 'auth_controller'

get '/tags', authenticate: :conditionally do
  @tag_counts =
    Tag.all.joins(:recipe_tags).group(:name, :slug).order(:name).count

  @page_title = 'Tags'
  erb :'tags/index'
end
