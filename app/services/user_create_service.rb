class UserCreateService
  class CreateError < StandardError
  end

  def initialize(user_params = {})
    @user_params = user_params
  end

  def call
    error!(user.errors.full_messages.first) unless user.valid?

    user.tap(&:save!)
  end

  private

  def error!(msg)
    raise CreateError.new(msg)
  end

  def user
    @user ||=
      User.new(name: @user_params['name'], password: @user_params['password'])
  end
end
