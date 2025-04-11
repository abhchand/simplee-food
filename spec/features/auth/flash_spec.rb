require 'sinatra_helper'

RSpec.feature 'Flash', type: :feature, js: true do
  let(:recipe) { FactoryBot.create(:recipe) }
  let(:user) { FactoryBot.create(:user) }

  it 'can dismiss a flash set via ERB' do
    # Force a flash message by logging in with a bad password
    visit '/login'
    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: 'bad-password')
    click_button('log in')

    # Flash exists - click "dismiss"
    within('.flash__content') do
      expect(page).to have_content('Invalid credentials')
      click_link('dismiss')
    end

    # Flash should no longer exist
    expect(page).to_not have_selector('#flash')
  end

  it 'can dismiss a flash set via JS' do
    log_in(user)

    # Force a flash message by causing an issue when deleting a recipe
    visit "/recipes/#{recipe.slug}"
    allow(Recipe).to receive(:find_by_slug) { nil }
    accept_confirm { page.find('.recipes-show__delete-btn a').click }

    # Flash exists - click "dismiss"
    within('.flash__content') do
      expect(page).to have_content('Unable to delete Recipe')
      click_link('dismiss')
    end

    # Flash should no longer exist
    expect(page).to_not have_selector('#flash')
  end
end
