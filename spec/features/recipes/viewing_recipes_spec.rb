require 'sinatra_helper'

RSpec.feature 'Viewing Recipes', type: :feature do
  let!(:recipe) do
    FactoryBot.create(
      :recipe,
      ingredients: %w[coconut apple banana pear],
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

  describe 'fullscreen mode', js: true do
    it 'user can view the recipe in fullscreen mode' do
      click_fullscreen_open

      # Slide 0: Ingredients
      expect_fullscreen_slide_to_have('coconut')

      # Slide 1
      click_fullscreen_nav_next
      expect_fullscreen_slide_to_have('wash banana')

      # Slide 2
      click_fullscreen_nav_next
      expect_fullscreen_slide_to_have('chop apple')

      # Slide 3
      click_fullscreen_nav_next
      expect_fullscreen_slide_to_have('boil the pear')

      # Slide 3
      # Clicking 'next' on the last page should not change pages
      click_fullscreen_nav_next
      expect_fullscreen_slide_to_have('boil the pear')

      # Slide 2
      click_fullscreen_nav_prev
      expect_fullscreen_slide_to_have('chop apple')

      # Slide 1
      click_fullscreen_nav_prev
      expect_fullscreen_slide_to_have('wash banana')

      # Slide 0: Ingredients
      click_fullscreen_nav_prev
      expect_fullscreen_slide_to_have('coconut')

      # Slide 0: Ingredients
      # Clicking 'prev' on the first page should not change pages
      click_fullscreen_nav_prev
      expect_fullscreen_slide_to_have('coconut')

      click_fullscreen_nav_exit
    end

    it 'should reset to the first slide each time' do
      click_fullscreen_open

      # Slide 0: Ingredients
      expect_fullscreen_slide_to_have('coconut')

      # Slide 1
      click_fullscreen_nav_next
      expect_fullscreen_slide_to_have('wash banana')

      # Exit and Re-open
      click_fullscreen_nav_exit
      click_fullscreen_open

      # We should be back to the initial slide
      # Slide 0: Ingredients
      expect_fullscreen_slide_to_have('coconut')
    end
  end

  def click_fullscreen_nav_exit
    page.all('.recipe-fullscreen__nav button')[1].click

    expect(page).to_not have_selector('.recipe-fullscreen')
  end

  def click_fullscreen_nav_next
    page.all('.recipe-fullscreen__nav button')[2].click

    # The CSS transition takes 400ms
    sleep(0.4)
  end

  def click_fullscreen_nav_prev
    page.all('.recipe-fullscreen__nav button')[0].click

    # The CSS transition takes 400ms
    sleep(0.4)
  end

  def click_fullscreen_open
    within('.recipes-show__header-toolbar') { click_link('view fullscreen') }

    expect(page).to have_selector('.recipe-fullscreen', visible: true)
  end

  def expect_fullscreen_slide_to_have(text)
    # Capybara registers the current slide *and* previous slide as both visible
    # at any given time. The previous slide is just offscreen to the left, with
    # it's bounding rectangle's right edge at x = 0. Perhaps capybara registers
    # the 0 axis as an inclusive boundary when determining "visible".
    #
    # This is a tricky problem to workaround, so just settle for selecting all
    # visible slides and picking the last element.
    current_slide = page.all('.recipe-fullscreen__slide', visible: true).last
    within(current_slide) { expect(page).to have_content(text) }
  end
end
