require 'sinatra_helper'

RSpec.describe User, type: :model do
  subject { user }
  let(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    describe 'name' do
      it { should validate_presence_of(:name).with_message('can not be empty') }

      it do
        should validate_uniqueness_of(:name).case_insensitive.with_message(
                 'has already been taken'
               )
      end

      it do
        should validate_length_of(:name).is_at_most(10).with_message(
                 'can not be longer than 10 characters'
               )
      end
    end

    describe 'password' do
      it do
        should validate_presence_of(:password).with_message('can not be empty')
      end

      it do
        should validate_length_of(:password)
                 .is_at_least(6)
                 .is_at_most(32)
                 .with_short_message('must be at least 6 characters')
                 .with_long_message('can not be more than 32 characters')
      end
    end
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
