if !ENV['RACK_ENV'] == 'development'
  puts "\tSeeding will not run on non-development environments"
  return
end

if User.count >= 1
  puts "\tSkipping Seeding... data already exists"
  return
end

puts "\t=== Seeding Users"
User.create!(name: 'indra', password: 'sekrit')

puts "\t=== Seeding Tags"
(1..5).each { |i| Tag.create!(name: "Tag #{i}") }

puts "\t=== Seeding Recipes"
(1..5).each do |i|
  Recipe.create!(
    name: "Recipe #{i}",
    serving_size: "#{i} bowls",
    ingredients: ['2 Onions (diced)', '4 Bell Peppers', '3 Bananas (peeled)'],
    steps: [
      'Boil the banana',
      'Blend the onions',
      'Heat water to 1,500 degrees and add bell peppers'
    ]
  )
end

puts "\t=== Adding Tags to Recipes"
(1..10).each do |i|
  r = Recipe.all.sample
  t = Tag.all.sample

  RecipeTag.find_or_create_by(recipe: r, tag: t)
end
