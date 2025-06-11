require 'sinatra_helper'

RSpec.feature 'Creating Recipes', type: :feature do
  include FixtureHelpers

  let!(:recipe) do
    FactoryBot.create(
      :recipe,
      ingredients: %w[apple banana pear],
      instructions: %w[wash chop boil]
    )
  end
  let(:user) { FactoryBot.create(:user) }

  before do
    log_in(user)
    within('.recipe-title-bar') do
      click_button('Add Recipe')
      click_button('go')
    end
  end

  # "New Recipe" uses the same ERB template as "Edit Recipe".
  # The functionality is largely tested in the "editing recipes" spec. Limit
  # the specs here to just the basic functionality of creating a new recipe in
  # order to avoid repeating tested functionality.

  it 'user can create a new recipe', js: true do
    fill_in('recipe[name]', with: 'New Name')
    fill_in('recipe[source_url]', with: 'https://my-recipes.com')
    fill_in('recipe[serving_size]', with: '99 cups')
    select_image('atlanta-skyline.png')

    within('#recipe-ingredients') do
      click_add_button
      fill_in('recipe[ingredients][0]', with: 'apple')

      click_add_button
      fill_in('recipe[ingredients][1]', with: 'tomatoes')
    end

    within('#recipe-instructions') do
      click_add_button
      fill_in('recipe[instructions][0]', with: 'peel em')

      click_add_button
      fill_in('recipe[instructions][1]', with: 'smash em')
    end

    # Create a new tag
    page.accept_prompt(with: 'newtag') { click_button('add new tag') }

    expect do
      click_save!
      expect(page).to have_current_path('/recipes/new-name')
    end.to change { Recipe.count }.by(1)

    recipe = Recipe.last

    expect(recipe.name).to eq('New Name')
    expect(recipe.source_url).to eq('https://my-recipes.com')
    expect(recipe.serving_size).to eq('99 cups')
    expect(recipe.image).to_not be_nil
    expect(recipe.image_thumbnail).to_not be_nil
    expect(recipe.ingredients).to eq(%w[apple tomatoes])
    expect(recipe.instructions).to eq(['peel em', 'smash em'])
    expect(recipe.tags.map(&:name)).to eq(%w[newtag])
  end

  it 'user can cancel creating a recipe', js: true do
    fill_in('recipe[name]', with: 'New Name')

    expect do
      click_link('cancel')

      expect(page).to have_current_path('/recipes')
    end.to_not change { Recipe.count }
  end

  context 'an error occurs', js: true do
    it 'user receives feedback via a flash message' do
      expect do
        click_save!

        expect(page).to have_current_path('/recipes/new')
      end.to_not change { Recipe.count }

      expect_flash_message("Name can't be blank")
    end
  end

  def click_add_button
    page.find('.recipes-edit__add-sortable-item-btn').click
  end

  def click_save!
    # There's 2 save buttons - click the bottom one by default
    page.all('.recipes-edit__save-btn')[1].click
  end

  def select_image(fixture_name)
    attach_file('recipe[image]', fixture_path_for(fixture_name), visible: false)
  end
end
