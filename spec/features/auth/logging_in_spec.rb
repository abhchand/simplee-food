require 'sinatra_helper'

RSpec.feature 'Logging In', type: :feature, js: true do
  let(:recipe) { FactoryBot.create(:recipe) }
  let(:user) { FactoryBot.create(:user) }

  it 'can log in' do
    visit '/login'

    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: user.password)

    click_button('log in')

    expect(page).to have_current_path('/recipes')
  end

  it 'preserves destination when accessing a protected resource' do
    edit_path = "/recipes/#{recipe.slug}/edit"
    dest = URI.encode_www_form_component(edit_path)

    visit edit_path

    # Intercepted and re-routed to login page
    expect(page).to have_current_path("/login?dest=#{dest}")
    expect(page.find('.flash__content')).to have_content(
      'You must sign in first'
    )

    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: user.password)

    click_button('log in')

    # After loggin in, user is taken to original destination
    expect(page).to have_current_path(edit_path)
  end

  it 'preserves destination when logging in via a nav link' do
    show_path = "/recipes/#{recipe.slug}"
    dest = URI.encode_www_form_component(show_path)

    visit show_path
    page.find('.nav--auth').click

    # Intercepted and re-routed to login page
    expect(page).to have_current_path("/login?dest=#{dest}")

    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: user.password)

    click_button('log in')

    # After loggin in, user is taken to original destination
    expect(page).to have_current_path(show_path)
  end

  it 'preserves destination when accessing a protected resource' do
    dest_path = "/recipes/#{recipe.slug}/edit"
    dest = URI.encode_www_form_component(dest_path)

    visit "/login?dest=#{dest}"

    # Login once, incorrectly
    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: 'bad-password')
    click_button('log in')

    # We should still be on login page with dest param
    expect(page).to have_current_path("/login?dest=#{dest}")

    # Login again, correctly
    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: user.password)
    click_button('log in')

    # After loggin in, user is taken to original destination
    expect(page).to have_current_path(dest_path)
  end
end
