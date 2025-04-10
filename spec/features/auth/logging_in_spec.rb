require 'sinatra_helper'

RSpec.feature 'Logging In', type: :feature, js: true do
  let(:user) { FactoryBot.create(:user) }

  it 'can log in' do
    visit '/login'

    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: user.password)

    click_button('log in')

    expect(page).to have_current_path('/recipes')
  end
end
