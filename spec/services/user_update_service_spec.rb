require 'sinatra_helper'

RSpec.describe UserUpdateService, type: :service do
  let(:service) do
    UserUpdateService.new(current_user, target_user, user_params)
  end

  let!(:current_user) do
    FactoryBot.create(:user, name: 'orange', password: 'sekrit')
  end
  let!(:target_user) { current_user }

  # By default, perform a name update. Individual tests can override this as
  # needed
  let(:user_params) { { 'name' => 'yellow' } }

  describe '#call' do
    context 'updating username' do
      let(:user_params) { { 'name' => 'yellow' } }

      it 'updates the user with new username' do
        expect do service.call end.to change { current_user.reload.name }.from(
          'orange'
        ).to('yellow')
      end

      context 'one or more model errors occur' do
        before { user_params['name'] = 'some-long-disallowed-name' }

        it 'returns the first error' do
          msg = 'Name can not be longer than 10 characters'

          expect do
            expect do service.call end.to raise_error(
              UserUpdateService::UpdateError,
              msg
            )
          end.to_not change { current_user.reload.name }
        end
      end
    end

    context 'updating password' do
      let(:user_params) do
        {
          'current_password' => 'sekrit',
          'new_password' => 'shhhhh',
          'confirmation' => 'shhhhh'
        }
      end

      it 'updates the user with new password' do
        expect do service.call end.to change {
          current_user.reload.password
        }.from('sekrit').to('shhhhh')
      end

      context 'current password is incorrect' do
        before { user_params['current_password'] = 'something-incorrect' }

        it 'raises an error' do
          msg = 'Current password is incorrect'

          expect do
            expect do service.call end.to raise_error(
              UserUpdateService::UpdateError,
              msg
            )
          end.to_not change { current_user.reload.password }
        end
      end

      context 'new password and confirmation dont match' do
        before { user_params['confirmation'] = 'something-incorrect' }

        it 'raises an error' do
          msg = 'Password confirmation does not match password'

          expect do
            expect do service.call end.to raise_error(
              UserUpdateService::UpdateError,
              msg
            )
          end.to_not change { current_user.reload.password }
        end
      end

      context 'one or more model errors occur' do
        before do
          user_params['new_password'] = 'short'
          user_params['confirmation'] = 'short'
        end

        it 'returns the first error' do
          msg = 'Password must be at least 6 characters'

          expect do
            expect do service.call end.to raise_error(
              UserUpdateService::UpdateError,
              msg
            )
          end.to_not change { current_user.reload.password }
        end
      end
    end

    context 'updating both username and password simultaneously' do
      let(:user_params) do
        {
          'current_password' => 'sekrit',
          'new_password' => 'shhhhh',
          'confirmation' => 'shhhhh',
          'name' => 'orange'
        }
      end

      it 'raises an error' do
        msg = 'Unknown action'

        expect do
          expect do service.call end.to raise_error(
            UserUpdateService::UpdateError,
            msg
          )
        end.to_not change { current_user.reload.attributes }
      end
    end

    context 'current user is updating someone else' do
      let!(:target_user) { FactoryBot.create(:user) }

      it 'raises an error' do
        msg = 'Update disallowed'

        expect do
          expect do service.call end.to raise_error(
            UserUpdateService::UpdateError,
            msg
          )
        end.to_not change { current_user.reload.attributes }
      end
    end

    context 'current user is blank' do
      # The logic checks `target_user`. By setting `current_user` as nil, it
      # will apply to target user. And since both are `nil`, it will pass the
      # "Update disallowed" check and fall back on the actual error we are
      # testing
      let!(:current_user) { nil }

      it 'raises an error' do
        msg = 'User not found'

        expect do service.call end.to raise_error(
          UserUpdateService::UpdateError,
          msg
        )
      end
    end
  end
end
