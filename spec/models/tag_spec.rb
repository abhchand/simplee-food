require 'sinatra_helper'

RSpec.describe Tag, type: :model do
  subject { FactoryBot.create(:tag) }

  describe 'associations' do
    it { should have_many(:recipe_tags) }
    it { should have_many(:recipes) }
  end

  describe 'callbacks' do
    describe 'calculating slug' do
      let(:tag) { FactoryBot.build(:tag) }

      it 'calculates the slug' do
        tag.name = 'salt and pepper'
        tag.valid?

        expect(tag.slug).to eq('salt-and-pepper')
      end

      it 'avoids capital letters' do
        tag.name = 'Salt and pePPer'
        tag.valid?

        expect(tag.slug).to eq('salt-and-pepper')
      end

      it 'replaces special characters' do
        tag.name = 'salt & pepper'
        tag.valid?

        expect(tag.slug).to eq('salt-pepper')
      end

      it 'collapses whitespace' do
        tag.name = 'salt   and pepper'
        tag.valid?

        expect(tag.slug).to eq('salt-and-pepper')
      end

      it 'collapses dashes' do
        tag.name = 'salt &&-- pepper'
        tag.valid?

        expect(tag.slug).to eq('salt-pepper')
      end

      it 'removes leading and trailing dashes' do
        tag.name = '-salt and pepper-'
        tag.valid?

        expect(tag.slug).to eq('salt-and-pepper')
      end

      context 'updating record and `name` did not change' do
        before { tag.save! }

        it 'does not recalculate the slug' do
          expect do
            expect(tag).to_not receive(:to_slug)
            tag.update!(created_at: Time.now)
          end.to_not change { tag.reload.slug }
        end
      end

      context '`name` is nil' do
        it 'gracefully fails validation without raising an error' do
          tag.name = nil
          tag.valid?

          expect(tag.slug).to be_nil
          expect(tag).to_not be_valid
        end
      end
    end
  end

  describe 'validations' do
    describe 'name' do
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name).case_insensitive }
    end

    it { should validate_presence_of(:slug) }
  end

  describe '.remove_all_unused!' do
    it 'should remove all tags not associated to a recipe' do
      recipe = FactoryBot.create(:recipe)
      tag1 = FactoryBot.create(:tag)
      tag2 = FactoryBot.create(:tag)

      recipe.add_tag(tag2)

      expect do Tag.remove_all_unused! end.to change {
        Tag.order(:id).to_a
      }.from([tag1, tag2]).to([tag2])
    end
  end
end
