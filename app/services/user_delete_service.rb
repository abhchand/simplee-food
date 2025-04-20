class UserDeleteService
  class DeleteError < StandardError
  end

  def initialize(current_user, target_user)
    @current_user = current_user
    @target_user = target_user
  end

  def call
    error!('Invalid request') if @current_user == @target_user

    @target_user.destroy!
  end

  private

  def error!(msg)
    raise DeleteError.new(msg)
  end
end
