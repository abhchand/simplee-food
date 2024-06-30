# Auth mechanism adapted from https://stackoverflow.com/a/3560286/2490003

register do
  def authenticate(type)
    unless %w[conditionally always].include?(type.to_s)
      raise "Unknown authentication type '#{type}'"
    end

    require_auth = Config.find_by_key('ENFORCE_AUTH')&.value == '1'
    should_auth =
      type.to_s == 'always' || (type.to_s == 'conditionally' && require_auth)

    condition do
      if should_auth && @user.nil?
        flash[:notice] = 'You must sign in first'
        redirect '/login'
      end
    end
  end
end

before do
  if session[:expires_at] && Time.at(session[:expires_at]) > Time.now
    @user = User.find_by_id(session[:user_id])
  end
end

get '/login' do
  erb :'auth/login'
end

post '/login' do
  username = params['login']['username']
  password = params['login']['password']

  user = User.find_by_name(username)
  if user.nil?
    flash[:error] = 'Invalid credentials'
    redirect '/login'
  end

  if user.password != password
    flash[:error] = 'Invalid credentials'
    redirect '/login'
  end

  session[:user_id] = user.id
  session[:expires_at] = (Time.now + (60 * 60 * 24) * 7).to_i # 7 days from now
  redirect to('/recipes')
end

get '/logout' do
  session[:user_id] = nil
  session[:expires_at] = nil

  flash[:notice] = 'You have been logged out'

  redirect to('/login')
end
