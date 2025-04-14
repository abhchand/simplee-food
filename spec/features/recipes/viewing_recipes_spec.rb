require 'sinatra_helper'

RSpec.feature 'Viewing Recipes', type: :feature do
  let!(:recipe) do
    FactoryBot.create(
      :recipe,
      ingredients: %w[apple banana pear],
      instructions: ['wash banana', 'chop apple', 'boil the pear']
    )
  end
  let(:user) { FactoryBot.create(:user) }

  before do
    log_in(user)
    visit "/recipes/#{recipe.slug}"
  end

  it 'user can navigate to the recipe page from the recipe list' do
    # User can click on the recipe name

    visit '/recipes'

    within(".recipes-index__item[data-name='#{recipe.slug}']") do
      click_link(recipe.name)
    end
    expect(page).to have_current_path("/recipes/#{recipe.slug}")

    # User can click on the recipe image

    visit '/recipes'

    within(".recipes-index__item[data-name='#{recipe.slug}']") do
      page.find('.recipes-index__item--image a').click
    end
    expect(page).to have_current_path("/recipes/#{recipe.slug}")
  end

  it 'user can toggle ingredients and instructions', js: true do
    # User can toggle ingredients
    within('.recipes-show__ingredients') do
      # Check the 'banana'checkbox
      expect(page).to have_unchecked_field('banana')
      check('banana')
      expect(page).to have_checked_field('banana')

      # Other items should remain unchecked
      expect(page).to have_unchecked_field('apple')
      expect(page).to have_unchecked_field('pear')
    end

    # User can toggle instructions
    el = page.find(".recipes-show__instruction-item[data-id='2']")
    expect do el.click end.to change { el[:class].include?('selected') }.from(
      false
    ).to(true)
  end
end
