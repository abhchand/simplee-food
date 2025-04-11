module FeatureHelpers
  def log_in(user)
    visit '/login'

    fill_in('login[username]', with: user.name)
    fill_in('login[password]', with: user.password)

    click_button('log in')

    expect(page).to have_current_path('/recipes')
  end

  def log_out
    click_link('logout')

    expect(page).to have_current_path('/recipes')
    expect(page.find('.flash__content')).to have_content(
      'You have been logged out'
    )
  end
end
