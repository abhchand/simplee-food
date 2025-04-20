require_relative 'auth_controller'

put '/users', authenticate: :conditionally do
  begin
    user = UserCreateService.new(params['user']).call
    flash[:success] = "Added #{user.name}"
  rescue UserCreateService::CreateError => e
    flash[:error] = e.message
  end

  redirect(back)
end

put '/users/:id', authenticate: :conditionally do
  @target_user = User.find_by_id(params['id'])
  return(status 404) unless @target_user

  begin
    field =
      UserUpdateService.new(@current_user, @target_user, params['user']).call
    flash[:success] = "Updated #{field} successfully"
  rescue UserUpdateService::UpdateError => e
    flash[:error] = e.message
  end

  redirect(back)
end

delete '/users/:id', authenticate: :conditionally do
  @target_user = User.find_by_id(params['id'])
  return(status 404) unless @target_user

  begin
    UserDeleteService.new(@current_user, @target_user).call
    flash[:success] = "Deleted #{@target_user.name}"
  rescue UserDeleteService::DeleteError => e
    flash[:error] = e.message
  end

  redirect(back)
end
