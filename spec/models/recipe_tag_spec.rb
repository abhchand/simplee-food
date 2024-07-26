require 'sinatra_helper'

RSpec.describe RecipeTag, type: :model do
  subject { FactoryBot.create(:recipe_tag) }

  describe 'associations' do
    it { should belong_to(:recipe) }
    it { should belong_to(:tag) }
  end

  describe 'validations' do
    it { should validate_presence_of(:recipe_id) }

    describe 'tag' do
      it { should validate_presence_of(:tag_id) }
      it { should validate_uniqueness_of(:tag_id).scoped_to(:recipe_id) }
    end
  end
end
