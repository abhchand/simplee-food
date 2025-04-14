class Recipe < ActiveRecord::Base
  include SlugHelper

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags, source: :tag, inverse_of: :recipes

  validates :name, presence: true
  validates :slug, presence: true

  validate do |recipe|
    # source_url
    if recipe.source_url.present?
      is_valid = recipe.source_url =~ /\A#{URI.regexp(%w[http https])}\z/
      errors.add(:source_url, 'Invalid URL') if !is_valid
    end
  end

  before_validation :calculate_slug

  def add_tag(tag)
    RecipeTag.find_or_create_by(recipe: self, tag: tag)
  end

  def ingredients
    return [] if self[:ingredients].nil?

    JSON.parse(self[:ingredients])
  end

  def ingredients=(val)
    self[:ingredients] = val&.to_json
  end

  def instructions
    return [] if self[:instructions].nil?

    JSON.parse(self[:instructions])
  end

  def rm_tag(tag)
    rt = RecipeTag.find_by(recipe: self, tag: tag)
    rt.destroy! if rt.present?
  end

  def instructions=(val)
    self[:instructions] = val&.to_json
  end

  private

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError => e
    false
  end
end
