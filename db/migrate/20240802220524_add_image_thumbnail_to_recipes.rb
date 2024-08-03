class AddImageThumbnailToRecipes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipes, :image_thumbnail, :binary
  end
end
