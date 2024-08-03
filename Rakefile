require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./app/app"
  end
end

namespace :simplee_food do
  task :create_initial_user do
    require "./app/app"

    next if User.count > 0

    User.create!(name: 'admin', password: 'sekrit')
  end
end
