require 'sinatra_helper'

RSpec.describe UserDeleteService, type: :service do
  let(:service) { UserDeleteService.new(current_user, target_user) }
  let!(:current_user) { FactoryBot.create(:user) }
  let!(:target_user) { FactoryBot.create(:user) }

  describe '#call' do
    it 'deletes the user' do
      expect do service.call end.to change { User.count }.by(-1)

      expect { current_user.reload }.to_not raise_error
      expect { target_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'current user is deleting themselves' do
      let!(:target_user) { current_user }

      it 'raises an error' do
        msg = 'Invalid request'

        expect do
          expect do service.call end.to raise_error(
            UserDeleteService::DeleteError,
            msg
          )
        end.to_not change { User.count }
      end
    end
  end
end
