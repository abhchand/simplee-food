class RecipeTag < ActiveRecord::Base
  belongs_to :recipe, inverse_of: :recipe_tags
  belongs_to :tag, inverse_of: :recipe_tags

  validates :recipe_id, presence: true
  validates :tag_id, presence: true, uniqueness: { scope: :recipe_id }
end
