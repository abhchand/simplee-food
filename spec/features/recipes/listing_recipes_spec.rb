require 'sinatra_helper'

RSpec.feature 'Listing Recipes', type: :feature, js: true do
  let!(:recipes) do
    [
      FactoryBot.create(:recipe, name: 'Georgia'),
      FactoryBot.create(:recipe, name: 'South Carolina'),
      FactoryBot.create(:recipe, name: 'Alaska'),
      FactoryBot.create(:recipe, name: 'California')
    ]
  end
  let(:user) { FactoryBot.create(:user) }

  before do
    stub_const('RecipeSearchService::DEFAULT_PAGE_SIZE', 2)
    log_in(user)
  end

  it 'can view the paginated recipe list' do
    # recipes are sorted by updated_at: desc by default.
    #   - page 1:  recipes[3], recipes[2]
    #   - page 2:  recipes[1], recipes[0]

    # page 1
    expect_displayed_recipes_to_be([recipes[3], recipes[2]])

    # page 2
    click_next_page
    expect_displayed_recipes_to_be([recipes[1], recipes[0]])

    # page 1 (again)
    click_prev_page
    expect_displayed_recipes_to_be([recipes[3], recipes[2]])
  end

  describe 'sorting recipes' do
    it 'can sort recipes by recent or by name' do
      # when sorting by name, the results are
      #   - page 1:  recipes[2], recipes[3]
      #   - page 2:  recipes[0], recipes[1]

      sort_by!(:name)
      expect_displayed_recipes_to_be([recipes[2], recipes[3]])

      # when sorting by recent, the results are
      #   - page 1:  recipes[3], recipes[2]
      #   - page 2:  recipes[1], recipes[0]

      sort_by!(:recent)
      expect_displayed_recipes_to_be([recipes[3], recipes[2]])
    end

    it 'can paginate the sorted results' do
      # when sorting by name, the results are
      #   - page 1:  recipes[2], recipes[3]
      #   - page 2:  recipes[0], recipes[1]

      # page 1
      sort_by!(:name)
      expect_displayed_recipes_to_be([recipes[2], recipes[3]])

      # page 2
      click_next_page
      expect_displayed_recipes_to_be([recipes[0], recipes[1]])

      # page 1 (again)
      click_prev_page
      expect_displayed_recipes_to_be([recipes[2], recipes[3]])
    end
  end

  describe 'searching recipes' do
    it 'can search recipes' do
      # when searching by "ia" and sorting by recent (default), the results are
      #   - page 1:  recipes[3], recipes[0]
      #   - page 2:  -

      # page 1
      search_recipes_for('ia')
      expect_displayed_recipes_to_be([recipes[3], recipes[0]])
    end

    it 'can clear the search' do
      search_recipes_for('ia')

      # recipes are sorted by updated_at: desc by default.
      #   - page 1:  recipes[3], recipes[2]
      #   - page 2:  recipes[1], recipes[0]

      # page 1
      clear_recipe_search!
      expect_displayed_recipes_to_be([recipes[3], recipes[2]])
    end

    it 'can paginate the search results' do
      # when searching by "o" and sorting by recent (default), the results are
      #   - page 1:  recipes[3], recipes[1]
      #   - page 2:  recipes[0]

      # page 1
      search_recipes_for('o')
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])

      # page 2
      click_next_page
      expect_displayed_recipes_to_be([recipes[0]])

      # page 1 (again)
      click_prev_page
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])
    end

    it 'can sort the paginated search results' do
      # when searching by "o" and sorting by name, the results are
      #   - page 1:  recipes[3], recipes[0]
      #   - page 2:  recipes[1]

      # page 1
      search_recipes_for('o')
      sort_by!(:name)
      expect_displayed_recipes_to_be([recipes[3], recipes[0]])

      # when searching by "o" and sorting by recent (default), the results are
      #   - page 1:  recipes[3], recipes[1]
      #   - page 2:  recipes[0]

      # page 1
      sort_by!(:recent)
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])
    end
  end

  describe 'searching by a tag' do
    let(:tag) { FactoryBot.create(:tag, name: 'mainland') }

    before do
      # Tag everything _except_ "Alaska" with the tag
      FactoryBot.create(:recipe_tag, recipe: recipes[0], tag: tag)
      FactoryBot.create(:recipe_tag, recipe: recipes[1], tag: tag)
      FactoryBot.create(:recipe_tag, recipe: recipes[3], tag: tag)

      # Reload page so newly created tags are displayed
      visit current_path

      # Filter by the tag
      # Since there's only 1 tag, we blindly click on the first tag we find
      within('.recipes-index__tags') { click_link('mainland') }
      expect(page).to have_current_path('/recipes?tag=mainland')
    end

    it 'can search recipes' do
      # when searching by "ia" and sorting by recent (default), the results are
      #   - page 1:  recipes[3], recipes[0]
      #   - page 2:  -

      # page 1
      search_recipes_for('ia')
      expect_displayed_recipes_to_be([recipes[3], recipes[0]])
    end

    it 'can clear the search' do
      search_recipes_for('ia')

      # recipes are sorted by updated_at: desc by default.
      #   - page 1:  recipes[3], recipes[1]
      #   - page 2:  recipes[0]

      # page 1
      clear_recipe_search!
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])
    end

    it 'can paginate the search results' do
      # when searching by "o" and sorting by recent (default), the results are
      #   - page 1:  recipes[3], recipes[1]
      #   - page 2:  recipes[0]

      # page 1
      search_recipes_for('o')
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])

      # page 2
      click_next_page
      expect_displayed_recipes_to_be([recipes[0]])

      # page 1 (again)
      click_prev_page
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])
    end

    it 'can sort the paginated search results' do
      # when searching by "o" and sorting by name, the results are
      #   - page 1:  recipes[3], recipes[0]
      #   - page 2:  recipes[1]

      # page 1
      sort_by!(:name)
      expect_displayed_recipes_to_be([recipes[3], recipes[0]])

      # when searching by "o" and sorting by recent (default), the results are
      #   - page 1:  recipes[3], recipes[1]
      #   - page 2:  recipes[0]

      # page 1
      sort_by!(:recent)
      expect_displayed_recipes_to_be([recipes[3], recipes[1]])
    end

    it 'can also list a specific tag by from the tags page' do
      within('nav') { click_link('tags') }
      within('.tags-index__list') { click_link('mainland') }

      expect(page).to have_current_path('/recipes?tag=mainland')
    end
  end

  def clear_recipe_search!
    page.find('.recipes-index__search-clear-btn').click
  end

  def click_next_page
    page.all('.recipes-index__pagination .nav-arrow')[1].click
  end

  def click_prev_page
    page.all('.recipes-index__pagination .nav-arrow')[0].click
  end

  def expect_displayed_recipes_to_be(recipes)
    slugs = page.all('.recipes-index__item').map { |el| el['data-name'] }
    expect(slugs).to eq(recipes.map(&:slug))
  end

  def search_recipes_for(text)
    page.find('.recipes-index__search-input').base.send_keys(text)
    sleep(2)
  end

  def sort_by!(type)
    raise "invalid sort type #{type}" unless %w[recent name].include?(type.to_s)

    page.find(".recipes-index__sort-by--#{type}").click
  end
end
