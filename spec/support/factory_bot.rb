require 'factory_bot'

RSpec.configure { |config| config.include FactoryBot::Syntax::Methods }

FactoryBot.definition_file_paths = %w[./spec/factories]
FactoryBot.find_definitions
