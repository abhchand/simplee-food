require 'sinatra_helper'

RSpec.describe User, type: :model do
  subject { user }
  let(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    describe 'name' do
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name).case_insensitive }
    end

    it { should validate_presence_of(:password) }
  end

  describe 'callbacks' do
    describe 'canonicalizing name' do
      it 'downcases the name' do
        user.name = 'Foo'
        user.valid?

        expect(user.name).to eq('foo')
      end

      it 'strips whitespace from the name' do
        user.name = ' foo '
        user.valid?

        expect(user.name).to eq('foo')
      end

      context 'name is nil' do
        it 'gracefully continues with validation' do
          user.name = nil
          expect { user.valid? }.to_not raise_error
        end
      end
    end
  end
end
