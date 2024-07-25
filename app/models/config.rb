class Config < ActiveRecord::Base
  self.primary_key = :key

  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.lookup(key)
    Config.find_by_key(key)&.value
  end
end
