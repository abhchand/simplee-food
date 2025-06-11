require 'sinatra_helper'

RSpec.feature 'Importing Recipes', type: :feature do
  include RecipeImportHelpers

  let(:url) { 'http://example.com' }
  let(:user) { FactoryBot.create(:user) }

  before do
    log_in(user)
    within('.recipe-title-bar') { click_button('Add Recipe') }
  end

  it 'user can import a recipe from a URL', js: true do
    data = { '@type' => 'Recipe', 'name' => 'Avocado Toast' }
    mock_site!(data)

    choose('Import recipe from URL')
    fill_in('import_url', with: url)

    expect do
      click_button('go')
      sleep(2)
      expect(page).to have_current_path('/recipes')
    end.to change { Recipe.count }.by(1)

    expect(Recipe.last.name).to eq('Avocado Toast')

    within('.flash__content') do
      expect(page).to have_content('Successfully imported 1 recipe.')
    end
  end

  it 'user can import multiple recipes from a URL', js: true do
    data = [
      { '@type' => 'Recipe', 'name' => 'Avocado Toast' },
      { '@type' => 'Recipe', 'name' => 'Banana Pancakes' }
    ]
    mock_site!(data)

    choose('Import recipe from URL')
    fill_in('import_url', with: url)

    expect do
      click_button('go')
      sleep(2)
      expect(page).to have_current_path('/recipes')
    end.to change { Recipe.count }.by(2)

    expect(Recipe.last(2).map(&:name)).to match_array(
      ['Avocado Toast', 'Banana Pancakes']
    )

    within('.flash__content') do
      expect(page).to have_content('Successfully imported 2 recipes.')
    end
  end

  it 'user can change their mind and create a recipe manually', js: true do
    choose('Import recipe from URL')
    fill_in('import_url', with: url)

    choose('Create new recipe')

    click_button('go')

    expect(page).to have_current_path('/recipes/new')
  end

  context 'import is not successful', js: true do
    before do
      expect(RecipeImport::ScrapingService).to receive(:new).and_raise('boo')
    end

    it 'user sees an error that is cleared on input change' do
      choose('Import recipe from URL')
      fill_in('import_url', with: url)

      expect do
        click_button('go')
        expect(page).to have_current_path('/recipes')
      end.to_not change { Recipe.count }

      # A modal error is displayed
      expect_modal_error

      # Changing the input clears the error
      fill_in('import_url', with: url)
      expect_no_modal_error
    end

    it 'user sees an error that is cleared on radio selection change' do
      choose('Import recipe from URL')
      fill_in('import_url', with: url)

      expect do
        click_button('go')
        expect(page).to have_current_path('/recipes')
      end.to_not change { Recipe.count }

      # A modal error is displayed
      expect_modal_error

      # Changing the radio selection clears the error
      choose('Create new recipe')
      expect_no_modal_error
    end
  end

  def expect_modal_error
    within('#recipe-create-modal') do
      expect(page.find('.modal--error').text).to eq('Unable to import from URL')
    end
  end

  def expect_no_modal_error
    within('#recipe-create-modal') do
      expect(page).to_not have_selector('.modal--error')
    end
  end
end
