require 'sinatra_helper'

RSpec.feature 'Logging Out', type: :feature, js: true do
  let(:user) { FactoryBot.create(:user) }

  it 'can log out' do
    log_in(user)

    click_link('logout')

    expect(page).to have_current_path('/recipes')
    expect(page.find('.flash__content')).to have_content(
      'You have been logged out'
    )
  end
end
