class Config < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.lookup(key)
    Config.find_by_key(key)&.value
  end
end
