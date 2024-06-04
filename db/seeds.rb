if !ENV['RACK_ENV'] == 'development'
  puts "\tSeeding will not run on non-development environments"
  return
end

if Widget.count > 0
  puts "\tData already exists... skipping"
  return
end

# ########################################################################

puts "\t=== Seeding Widgets"
w1 = Widget.create!(name: 'Foo')

puts "\t=== Seeding Users"
User.create!(name: 'indra', password: 'purpose')
