post '/widget', auth: :user do
  Time.zone = 'UTC'

  name = params[:name]
  if name.nil? || name == ''
    flash[:error] = 'PLEASE ENTER YOUR NAME'
    redirect to('/')
    return
  end

  Widget.create!(name: name)
  redirect to('/')
end
