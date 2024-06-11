class Recipe < ActiveRecord::Base
  include SlugHelper

  validates :name, presence: true
  validates :slug, presence: true

  validate do |recipe|
    # # ingredients
    # if recipe.ingredients.present? && !valid_json?(recipe.ingredients)
    #   errors.add(:ingredients, 'Invalid JSON')
    # end

    # # steps
    # if recipe.steps.present? && !valid_json?(recipe.steps)
    #   errors.add(:steps, 'Invalid JSON')
    # end

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

  # Attempts to slug-ify the `name` of the recipe
  #
  # e.g. 'Idli and Rasam' becomes 'idli-and-rasam'
  #
  # If conflicts exist, we add a suffix `-2`, `-3`, etc...
  def calculate_slug
    # If we're updating and name didn't change - don't do anything
    return if persisted? && !name_changed?

    slug = to_slug(name)
    suffix = 1

    # Keep looping till we find a valid slug name we can use
    loop do
      # We never use `-1` as a suffix. We start with `-2`, if needed
      slug = [slug, suffix == 1 ? nil : suffix].compact.join('-')
      recipe = Recipe.find_by_slug(slug)

      if recipe.nil?
        self[:slug] = slug
        break
      end

      suffix += 1
    end
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError => e
    false
  end
end
