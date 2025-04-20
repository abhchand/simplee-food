require 'sinatra_helper'

RSpec.feature 'Manage Users', type: :feature do
  let(:users) do
    [
      FactoryBot.create(:user, name: 'alpha'),
      FactoryBot.create(:user, name: 'bravo'),
      FactoryBot.create(:user, name: 'delta')
    ]
  end

  before do
    log_in(users[0])
    visit '/settings'
  end

  context 'deleting users' do
    it 'user can delete others users' do
      expect_user_list_to_be([users[0], users[1], users[2]])

      # Delete User 1
      expect { delete_user(users[1]) }.to change { User.count }.by(-1)
      expect_flash_message("Deleted #{users[1].name}")
      expect_user_list_to_be([users[0], users[2]])

      # Delete User 2
      expect { delete_user(users[2]) }.to change { User.count }.by(-1)
      expect_flash_message("Deleted #{users[2].name}")
      expect_user_list_to_be([users[0]])
    end

    context 'an error occurs' do
      before do
        # There's no easy way to cause a deletion error through the UI
        # Simulatone one
        allow_any_instance_of(UserDeleteService).to receive(:call).and_raise(
          UserDeleteService::DeleteError,
          'boo'
        )
      end

      it 'user sees a flash error' do
        # Try deleting User 1
        expect { delete_user(users[1]) }.to_not change { User.count }
        expect_flash_message('boo')
        expect_user_list_to_be([users[0], users[1], users[2]])
      end
    end
  end

  context 'adding a new user' do
    it 'user can invite another user' do
      fill_in('new-user-username', with: 'purple')
      fill_in('new-user-password', with: 'sekrit')

      expect do
        within('.settings__section--new-user') { click_button('add') }
      end.to change { User.count }.by(1)

      user = User.last
      expect(user.name).to eq('purple')
      expect(user.password).to eq('sekrit')

      expect_flash_message('Added purple')
    end

    context 'an error occurrs' do
      it 'user sees a flash error' do
        fill_in('new-user-username', with: 'purple')
        fill_in('new-user-password', with: '')

        expect do
          within('.settings__section--new-user') { click_button('add') }
        end.to_not change { User.count }

        expect_flash_message('Password can not be empty')
      end
    end
  end

  def delete_user(user)
    page.find(
      ".settings__delete-user-form-submit-btn[data-id='#{user.id}']"
    ).click

    # Force wait page reload
    expect(page).to have_current_path('/settings')
  end

  def expect_user_list_to_be(users)
    names = page.all('.settings__user-list li span').map { |el| el.text.strip }

    expect(users.map(&:name)).to eq(names)
  end
end
