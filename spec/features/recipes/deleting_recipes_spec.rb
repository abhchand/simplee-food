require 'sinatra_helper'

RSpec.feature 'Deleting Recipes', type: :feature do
  let!(:recipe) { FactoryBot.create(:recipe) }
  let(:user) { FactoryBot.create(:user) }

  before do
    log_in(user)
    visit "/recipes/#{recipe.slug}"
  end

  it 'user can delete a recipe', js: true do
    expect do
      accept_confirm { page.find('.recipes-show__delete-btn a').click }

      # have_current_path will wait till the desired path loads
      expect(page).to have_current_path('/recipes')
    end.to change { Recipe.find_by_id(recipe.id).nil? }.from(false).to(true)
  end
end
