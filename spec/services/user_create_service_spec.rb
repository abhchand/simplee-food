require 'sinatra_helper'

RSpec.describe UserCreateService, type: :service do
  let(:service) { UserCreateService.new(user_params) }
  let(:user_params) { { 'name' => 'purple', 'password' => 'sekrit' } }

  describe '#call' do
    it 'creates the user' do
      expect do service.call end.to change { User.count }.by(1)

      user = User.last
      expect(user.name).to eq('purple')
      expect(user.password).to eq('sekrit')
    end

    context 'one or more errors occur' do
      before do
        user_params['name'] = 'some-long-disallowed-name'
        user_params['password'] = 'short'
      end

      it 'returns the first error' do
        msg = 'Name can not be longer than 10 characters'

        expect do
          expect do service.call end.to raise_error(
            UserCreateService::CreateError,
            msg
          )
        end.to_not change { User.count }
      end
    end
  end
end
