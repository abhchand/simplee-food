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

  def ingredients
    return if self[:ingredients].nil?

    JSON.parse(self[:ingredients])
  end

  def ingredients=(val)
    self[:ingredients] = val&.to_json
  end

  def steps
    return if self[:steps].nil?

    JSON.parse(self[:steps])
  end

  def steps=(val)
    self[:steps] = val&.to_json
  end

  private

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError => e
    false
  end
end
