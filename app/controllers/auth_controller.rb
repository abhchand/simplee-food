# Auth mechanism adapted from https://stackoverflow.com/a/3560286/2490003

register do
  def authenticate(type)
    unless %w[conditionally always].include?(type.to_s)
      raise "Unknown authentication type '#{type}'"
    end

    condition do
      require_auth = Config.lookup('ENFORCE_AUTH') == '1'
      should_auth =
        type.to_s == 'always' || (type.to_s == 'conditionally' && require_auth)

      if should_auth && @user.nil?
        flash[:notice] = 'You must sign in first'

        # The user hit an endpoint that requires authentication, but was not
        # authenticated. Preserve the original destination in a `dest` param
        # that can be used to redirect back here after successful login.
        dest =
          (
            if request.fullpath =~ %r{^/}
              URI.encode_www_form_component(request.fullpath)
            else
              '/recipes'
            end
          )
        redirect "/login?dest=#{dest}"
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
  # Calculate paths to redirect to on success and failure. If a `dest` param
  # exists we want to preserve that redirect on login.
  #
  # NOTE: The login page embeds `params[:dest]` as a hidden field so it gets
  # included in the POST data to this endpoint. Even if `dest` is URL encoded,
  # the rendered page and subsequent POST data automatically decode it. So
  # params[:dest] will always be URL decoded here (e.g. "/recipes/foo/edit")
  encoded_dest = URI.encode_www_form_component(params[:dest]) if params[:dest]
  failure_path = params[:dest] ? "/login?dest=#{encoded_dest}" : '/login'
  success_path = params[:dest] || '/recipes'

  #
  # Authenticate
  #

  username = params['login']['username']
  password = params['login']['password']

  user = User.find_by_name(username)
  if user.nil?
    flash[:error] = 'Invalid credentials'
    redirect to(failure_path)
  end

  if user.password != password
    flash[:error] = 'Invalid credentials'
    redirect to(failure_path)
  end

  #
  # Set Session
  #

  session[:user_id] = user.id
  session[:expires_at] = (Time.now + (60 * 60 * 24) * 7).to_i # 7 days from now
  redirect to(success_path)
end

get '/logout' do
  session[:user_id] = nil
  session[:expires_at] = nil

  flash[:notice] = 'You have been logged out'

  redirect to('/login')
end
