if !ENV['RACK_ENV'] == 'development'
  puts "\tSeeding will not run on non-development environments"
  return
end

puts "\t=== Seeding Users"
User.create!(name: 'indra', password: 'purpose')
