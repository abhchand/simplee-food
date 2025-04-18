class User < ActiveRecord::Base
  validates(
    :name,
    presence: {
      message: 'can not be empty'
    },
    uniqueness: {
      case_sensitive: false,
      message: 'has already been taken'
    },
    length: {
      maximum: 10,
      too_long: 'can not be longer than %{count} characters'
    }
  )

  validates(
    :password,
    presence: {
      message: 'can not be empty'
    },
    length: {
      minimum: 6,
      maximum: 32,
      too_long: 'can not be more than %{count} characters',
      too_short: 'must be at least %{count} characters'
    }
  )

  before_validation :canonicalize_name

  private

  def canonicalize_name
    return if name.nil?

    name.downcase!
    name.strip!
  end
end
