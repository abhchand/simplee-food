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

  it 'groups ingredients by `[tag]`', js: true do
    recipe.update!(
      ingredients: [
        '[foo] apple',
        'orange',
        '[bar] banana',
        '[Foo] pear',
        'cactus'
      ]
    )
    visit "/recipes/#{recipe.slug}"

    # Expected ordering:
    #   * 'foo' group (apple, pear) - placed where 'apple' was
    #   * orange
    #   * 'bar' group (banana)
    #   * cactus
    within('.recipes-show__ingredients') do
      expect_ingredient_entries_to_be(
        '.recipes-show__ingredient-group',
        '.recipes-show__ingredient',
        [%w[foo apple pear], 'orange', %w[bar banana], 'cactus']
      )

      # Tags are stripped from the labels
      expect(page).to_not have_content('[')

      # Checking an item within a group only checks that item
      check('pear')
      expect(page).to have_checked_field('pear')
      expect(page).to have_unchecked_field('apple')
      expect(page).to have_unchecked_field('orange')
    end
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

    it 'groups ingredients in cooking mode' do
      recipe.update!(ingredients: ['[foo] apple', 'orange', '[Foo] pear'])
      visit "/recipes/#{recipe.slug}"

      click_fullscreen_open

      within('.recipe-fullscreen__slide--ingredients') do
        expect_ingredient_entries_to_be(
          '.ingredient-group',
          '.ingredient',
          [%w[foo apple pear], 'orange']
        )

        expect(page).to_not have_content('[')
      end
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
    within('.recipes-show__header-toolbar') { click_link('cooking mode') }

    expect(page).to have_selector('.recipe-fullscreen', visible: true)
  end

  # Verifies the rendered order of ingredient groups and ungrouped items.
  #
  # Each element of `expected` is either a plain string (an ungrouped
  # ingredient) or an array of `[group_name, *ingredients]` (a group).
  def expect_ingredient_entries_to_be(group_selector, item_selector, expected)
    # Top-level entries are the groups plus any items *not* inside a group
    entries =
      page.all("#{group_selector}, #{item_selector}:not(#{group_selector} *)")

    actual =
      entries.map do |entry|
        if entry.matches_css?(group_selector)
          [entry.find('h3, h4').text] +
            entry.all(item_selector).map { |i| i.find('label').text }
        else
          entry.find('label').text
        end
      end

    expect(actual).to eq(expected)
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
