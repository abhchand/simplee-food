class User < ActiveRecord::Base
  validates :name, presence: true
  validates :password, presence: true

  before_validation :canonicalize_name

  private

  def canonicalize_name
    return if name.nil?

    name.downcase!
    name.strip!
  end
end
