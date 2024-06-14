class Tag < ActiveRecord::Base
  include SlugHelper

  has_many :recipe_tags, dependent: :destroy, inverse_of: :tag
  has_many :recipes, through: :recipe_tags, source: :recipe, inverse_of: :tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true

  before_validation :calculate_slug
end
