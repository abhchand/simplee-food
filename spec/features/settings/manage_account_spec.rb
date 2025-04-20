require 'sinatra_helper'

RSpec.feature 'Manage Account', type: :feature do
  let(:user) { FactoryBot.create(:user, name: 'purple', password: 'sekrit') }

  before do
    log_in(user)
    visit '/settings'
  end

  describe 'updating username' do
    it 'user can update their username' do
      fill_in('update-user-username', with: 'yellow')

      expect do
        within('.settings__section--change-username') { click_button('update') }
      end.to change { user.reload.name }.from('purple').to('yellow')
    end

    context 'an error occurs' do
      it 'user sees a flash error' do
        fill_in('update-user-username', with: '')

        expect do
          within('.settings__section--change-username') do
            click_button('update')
          end
        end.to_not change { user.reload.name }

        expect_flash_message('Name can not be empty')
      end
    end
  end

  describe 'updating password' do
    it 'user can update their password' do
      fill_in('update-user-current-password', with: 'sekrit')
      fill_in('update-user-new-password', with: 'shhhhh')
      fill_in('update-user-confirm-password', with: 'shhhhh')

      expect do
        within('.settings__section--change-password') { click_button('update') }
      end.to change { user.reload.password }.from('sekrit').to('shhhhh')
    end

    context 'an error occurs' do
      it 'user sees a flash error' do
        fill_in('update-user-current-password', with: 'sekrit')
        fill_in('update-user-new-password', with: 'shhhhh')
        fill_in('update-user-confirm-password', with: 'something-else')

        expect do
          within('.settings__section--change-password') do
            click_button('update')
          end
        end.to_not change { user.reload.password }

        expect_flash_message('Password confirmation does not match password')
      end
    end
  end
end
