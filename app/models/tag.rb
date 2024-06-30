class Tag < ActiveRecord::Base
  include SlugHelper

  has_many :recipe_tags, dependent: :destroy, inverse_of: :tag
  has_many :recipes, through: :recipe_tags, source: :recipe, inverse_of: :tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true

  before_validation :calculate_slug

  def self.remove_all_unused!
    Tag.find_by_sql(<<-SQL).each(&:destroy!)
      SELECT t.*
      FROM tags t
      LEFT JOIN recipe_tags rt ON rt.tag_id = t.id
      WHERE rt.id IS NULL
      SQL
  end
end
