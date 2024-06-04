# Auth mechanism adapted from https://stackoverflow.com/a/3560286/2490003

register do
  def auth(type)
    condition do
      unless send("is_#{type}?")
        flash[:notice] = 'You must sign in first'
        redirect '/login'
      end
    end
  end
end

helpers do
  def is_user?
    @user != nil
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
  redirect to('/')
end

get '/logout' do
  session[:user_id] = nil
  session[:expires_at] = nil

  flash[:notice] = 'You have been logged out'

  redirect to('/login')
end
