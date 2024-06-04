get '/health-check' do
  db_ok =
    begin
      ActiveRecord::Base.connection.active?
    rescue StandardError
      false
    end

  version = `git name-rev $(git rev-parse HEAD) --always`.strip

  content_type :json
  { db: db_ok, version: version }.to_json
end
