require 'sinatra_helper'

RSpec.describe Config, type: :model do
  subject { Config.create(key: 'FOO', value: 'bar') }

  describe 'validations' do
    describe 'key' do
      it { should validate_presence_of(:key) }
      it { should validate_uniqueness_of(:key) }
    end

    it { should validate_presence_of(:value) }
  end

  describe '.lookup' do
    let!(:config) { subject }

    it 'finds the config by key' do
      expect(Config.lookup('FOO')).to eq('bar')
    end

    context 'no config exists' do
      it 'returns nil' do
        expect(Config.lookup('SUP')).to be_nil
      end
    end
  end
end
