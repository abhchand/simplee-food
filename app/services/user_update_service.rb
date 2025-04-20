class UserUpdateService
  class UpdateError < StandardError
  end

  def initialize(current_user, target_user, user_params = {})
    @current_user = current_user
    @target_user = target_user
    @user_params = user_params
  end

  def call
    error!('Update disallowed') if @target_user != @current_user
    error!('User not found') if @target_user.nil?
    error!('Unknown action') if action_type.nil?

    send("update_#{action_type}")

    error!(@target_user.errors.full_messages.first) unless @target_user.valid?

    @target_user.tap(&:save!)
    action_type
  end

  private

  # Determine what type of update we're making
  #   * if a `name` was specified in the params, we are updating name
  #   * if a new password and confirmation was specified in the params, we
  #     are updating password.
  #
  # Note that this doesn't allow for a simultaneous update of both.
  def action_type
    @action_type ||=
      begin
        request_keys = @user_params.keys.map(&:to_s).sort

        {
          %w[name] => :name,
          %w[confirmation current_password new_password] => :password
        }[
          request_keys
        ]
      end
  end

  def error!(msg)
    raise UpdateError.new(msg)
  end

  def update_name
    @target_user.attributes = { name: @user_params['name'] }
  end

  def update_password
    if @user_params['current_password'] != @target_user.password
      error!('Current password is incorrect')
    end

    if @user_params['new_password'] != @user_params['confirmation']
      error!('Password confirmation does not match password')
    end

    @target_user.attributes = { password: @user_params['new_password'] }
  end
end
