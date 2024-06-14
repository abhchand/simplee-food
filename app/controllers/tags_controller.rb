get '/tags', auth: :user do
  @tag_counts =
    Tag.all.joins(:recipe_tags).group(:name, :slug).order(:name).count

  erb :'tags/index'
end
