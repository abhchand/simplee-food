require 'sinatra_helper'

RSpec.describe Recipe, type: :model do
  subject { recipe }
  let(:recipe) { FactoryBot.create(:recipe) }

  describe 'associations' do
    it { should have_many(:recipe_tags) }
    it { should have_many(:tags) }
  end

  describe 'callbacks' do
    describe 'calculating slug' do
      let(:recipe) { FactoryBot.build(:recipe) }

      it 'calculates the slug' do
        recipe.name = 'salt and pepper'
        recipe.valid?

        expect(recipe.slug).to eq('salt-and-pepper')
      end

      it 'avoids capital letters' do
        recipe.name = 'Salt and pePPer'
        recipe.valid?

        expect(recipe.slug).to eq('salt-and-pepper')
      end

      it 'replaces special characters' do
        recipe.name = 'salt & pepper'
        recipe.valid?

        expect(recipe.slug).to eq('salt-pepper')
      end

      it 'collapses whitespace' do
        recipe.name = 'salt   and pepper'
        recipe.valid?

        expect(recipe.slug).to eq('salt-and-pepper')
      end

      it 'collapses dashes' do
        recipe.name = 'salt &&-- pepper'
        recipe.valid?

        expect(recipe.slug).to eq('salt-pepper')
      end

      it 'removes leading and trailing dashes' do
        recipe.name = '-salt and pepper-'
        recipe.valid?

        expect(recipe.slug).to eq('salt-and-pepper')
      end

      context 'slug already exists' do
        before do
          FactoryBot.create(:recipe, name: 'salt', slug: 'salt')
          FactoryBot.create(:recipe, name: 'salt', slug: 'salt-2')
        end

        it 'appends an index to the slug until a unique slug is found' do
          recipe.name = 'salt'
          recipe.valid?

          expect(recipe.slug).to eq('salt-3')
        end
      end

      context 'updating record and `name` did not change' do
        before { recipe.save! }

        it 'does not recalculate the slug' do
          expect do
            expect(recipe).to_not receive(:to_slug)
            recipe.update!(source_url: 'https://example.com')
          end.to_not change { recipe.reload.slug }
        end
      end

      context '`name` is nil' do
        it 'gracefully fails validation without raising an error' do
          recipe.name = nil
          recipe.valid?

          expect(recipe.slug).to be_nil
          expect(recipe).to_not be_valid
        end
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }

    describe '#source_url' do
      it 'allows setting source_url' do
        recipe.source_url = 'https://example.com'
        expect(recipe).to be_valid
      end

      context 'source_url is invalid' do
        it 'Recipe fails validation' do
          recipe.source_url = 'foo'
          expect(recipe).to_not be_valid
        end
      end

      context 'source_url is not present' do
        it 'Recipe passes validation' do
          recipe.source_url = nil
          expect(recipe).to be_valid
        end
      end
    end
  end

  describe '#add_tag' do
    let(:tag) { FactoryBot.create(:tag) }

    it 'adds a tag' do
      expect do recipe.add_tag(tag) end.to change {
        recipe.reload.tags.to_a
      }.from([]).to([tag])
    end

    context 'tag already exists on this recipe' do
      before { RecipeTag.create!(recipe: recipe, tag: tag) }

      it 'does not create a new tag' do
        expect do recipe.add_tag(tag) end.to_not change {
          recipe.reload.tags.to_a
        }.from([tag])
      end
    end
  end

  describe '#ingredients' do
    it 'returns the ingredients as parsed JSON' do
      recipe[:ingredients] = "[\"onion\", \"carrot\"]"
      expect(recipe.ingredients).to eq(%w[onion carrot])
    end

    context 'ingredients is empty' do
      it 'returns []' do
        recipe[:ingredients] = nil
        expect(recipe.ingredients).to eq([])
      end
    end
  end

  describe '#ingredients=' do
    it 'stores the ingredients as raw JSON' do
      recipe.ingredients = %w[onion carrot]
      expect(recipe[:ingredients]).to eq("[\"onion\",\"carrot\"]")
    end

    context 'value is nil' do
      it 'gracefully stores the value as nil' do
        recipe.ingredients = nil
        expect(recipe[:ingredients]).to be_nil
      end
    end
  end

  describe '#steps' do
    it 'returns the steps as parsed JSON' do
      recipe[:steps] = "[\"onion\", \"carrot\"]"
      expect(recipe.steps).to eq(%w[onion carrot])
    end

    context 'steps is empty' do
      it 'returns []' do
        recipe[:steps] = nil
        expect(recipe.steps).to eq([])
      end
    end
  end

  describe '#rm_tag' do
    let(:tag) { FactoryBot.create(:tag) }

    it 'removes the tag' do
      RecipeTag.create!(recipe: recipe, tag: tag)

      expect do recipe.rm_tag(tag) end.to change {
        recipe.reload.tags.to_a
      }.from([tag]).to([])
    end

    context 'tag does not exist on the recipe' do
      it 'does nothing' do
        expect do recipe.rm_tag(tag) end.to_not change {
          recipe.reload.tags.to_a
        }.from([])
      end
    end
  end

  describe '#steps=' do
    it 'stores the steps as raw JSON' do
      recipe.steps = %w[onion carrot]
      expect(recipe[:steps]).to eq("[\"onion\",\"carrot\"]")
    end

    context 'value is nil' do
      it 'gracefully stores the value as nil' do
        recipe.steps = nil
        expect(recipe[:steps]).to be_nil
      end
    end
  end
end
