require 'sinatra_helper'

RSpec.describe RecipeUpdateService, type: :service do
  include FixtureHelpers

  let(:params) do
    {
      recipe: {
        name: 'Salty Cherries',
        source_url: 'https://example.co/food',
        serving_size: '3 cups',
        ingredients: {
          '0': '1 cherry',
          '1': '1/4 cup salt'
        },
        instructions: {
          '0': 'Boil the cherry',
          '1': 'Dump all the salt in'
        }
      }
    }
  end

  context 'recipe already exists' do
    let(:recipe) { FactoryBot.create(:recipe) }

    it 'updates the name' do
      expect do call! end.to change { recipe.reload.name }.to(
        params[:recipe][:name]
      )
    end

    describe 'updating source_url' do
      it 'updates the source_url' do
        expect do call! end.to change { recipe.reload.source_url }.to(
          params[:recipe][:source_url]
        )
      end

      it 'clears the source_url when it is specified as blank' do
        recipe.update!(source_url: 'https://something.non.nil/')
        params[:recipe][:source_url] = ''

        expect do call! end.to change { recipe.reload.source_url }.to(nil)
      end
    end

    describe 'updating serving_size' do
      it 'updates the serving_size' do
        expect do call! end.to change { recipe.reload.serving_size }.to(
          params[:recipe][:serving_size]
        )
      end

      it 'clears the serving_size when it is specified as blank' do
        recipe.update!(serving_size: 'something non nil')
        params[:recipe][:serving_size] = ''

        expect do call! end.to change { recipe.reload.serving_size }.to(nil)
      end
    end

    describe 'updating ingredients' do
      it 'updates the ingredients' do
        expect do call! end.to change { recipe.reload.ingredients }.to(
          params[:recipe][:ingredients].values
        )
      end

      it 'clears the ingredients when it is specified as blank' do
        recipe.update!(ingredients: ['thing 1', 'thing 2'])
        params[:recipe].delete(:ingredients)

        expect do call! end.to change { recipe.reload.ingredients }.to([])
      end
    end

    describe 'updating instructions' do
      it 'updates the instructions' do
        expect do call! end.to change { recipe.reload.instructions }.to(
          params[:recipe][:instructions].values
        )
      end

      it 'clears the instructions when it is specified as blank' do
        recipe.update!(instructions: ['instruction 1', 'instruction 2'])
        params[:recipe].delete(:instructions)

        expect do call! end.to change { recipe.reload.instructions }.to([])
      end
    end

    context 'updating image' do
      let(:fixture_name) { 'atlanta-skyline.png' }
      let(:tempfile) { create_tempfile_from_fixture(fixture_name) }

      before do
        params[:recipe][:image] = {
          filename: fixture_name,
          type: 'image/png',
          name: 'recipe[image]',
          tempfile: tempfile,
          head: 'Content-Disposition: blah blah'
        }
      end

      after do
        tempfile.close
        tempfile.unlink
      end

      it 'updates the image' do
        expect do call! end.to change { !recipe.reload.image.nil? }.from(
          false
        ).to(true)

        expect(recipe.image).to match(%r{image/png;base64,.*})
      end

      it 'updates the image thumbnail' do
        expect do call! end.to change {
          !recipe.reload.image_thumbnail.nil?
        }.from(false).to(true)

        expect(recipe.image_thumbnail).to match(%r{image/png;base64,.*})
      end

      it 'does not clear the image when it is specified as blank' do
        # Pretend an image already exists on the `Recipe` instance
        recipe.update!(
          image: 'image/png;base64,abcde',
          image_thumbnail: 'image/png;base64,fghij'
        )

        params[:recipe][:image] = nil

        # Neither `image` or `image_thumbnail` should be changed/nullified
        expect do
          expect do call! end.to_not change { !recipe.reload.image.nil? }.from(
            true
          )
        end.to_not change { !recipe.reload.image_thumbnail.nil? }.from(true)
      end
    end

    context 'updating tags' do
      let(:tag) { FactoryBot.create(:tag) }

      it 'can add tags to the recipe' do
        params[:recipe][:tag_ids] = [tag.id]

        expect do call! end.to change { recipe.reload.tags }.from([]).to([tag])
      end

      it 'can remove tags from the recipe' do
        params[:recipe][:tag_ids] = []
        recipe.add_tag(tag)

        expect do call! end.to change { recipe.reload.tags }.from([tag]).to([])
      end

      context 'tag being added does not already exist' do
        before { params[:recipe][:tag_names] = ['New Tag'] }

        it 'creates the tag' do
          expect do call! end.to change { Tag.count }.by(1)

          expect(Tag.last.name).to eq('New Tag')
        end

        it 'adds the tag to the recipe' do
          expect do call! end.to change { recipe.reload.tags }.from([])

          tag = Tag.last
          expect(recipe.tags).to eq([tag])
        end
      end

      context 'tag being removed does not belong to any other recipe' do
        let(:other_tag) { FactoryBot.create(:tag) }

        before do
          # Ensure the recipe is tagged with `tag` and `other_tag`
          recipe.add_tag(tag)
          recipe.add_tag(other_tag)

          # We want to remove `tag`, leaving only `other_tag`
          params[:recipe][:tag_ids] = [other_tag]
        end

        it 'removes the tag from the recipe' do
          expect do call! end.to change { recipe.reload.tags.order(:id) }.from(
            [tag, other_tag]
          ).to([other_tag])
        end

        it 'deletes the tag' do
          expect do call! end.to change { Tag.order(:id) }.from(
            [tag, other_tag]
          ).to([other_tag])
        end
      end
    end
  end

  context 'recipe does exist' do
    let(:recipe) { Recipe.new }

    it 'creates a new Recipe record' do
      expect do call! end.to change { Recipe.count }.by(1)
    end

    it 'sets the name' do
      call!
      expect(recipe.reload.name).to eq(params[:recipe][:name])
    end

    it 'sets the source_url' do
      call!
      expect(recipe.reload.source_url).to eq(params[:recipe][:source_url])
    end

    it 'sets the serving_size' do
      call!
      expect(recipe.reload.serving_size).to eq(params[:recipe][:serving_size])
    end

    it 'sets the ingredients' do
      call!
      expect(recipe.reload.ingredients).to eq(
        params[:recipe][:ingredients].values
      )
    end

    it 'sets the instructions' do
      call!
      expect(recipe.reload.instructions).to eq(
        params[:recipe][:instructions].values
      )
    end

    describe 'updating image' do
      let(:fixture_name) { 'atlanta-skyline.png' }
      let(:tempfile) { create_tempfile_from_fixture(fixture_name) }

      before do
        params[:recipe][:image] = {
          filename: fixture_name,
          type: 'image/png',
          name: 'recipe[image]',
          tempfile: tempfile,
          head: 'Content-Disposition: blah blah'
        }
      end

      after do
        tempfile.close
        tempfile.unlink
      end

      it 'updates the image' do
        call!
        expect(recipe.reload.image).to match(%r{image/png;base64,.*})
      end

      it 'updates the image thumbnail' do
        call!
        expect(recipe.reload.image_thumbnail).to match(%r{image/png;base64,.*})
      end
    end

    describe 'updating tags' do
      it 'adds the tags to the recipe' do
        tag = FactoryBot.create(:tag)
        params[:recipe][:tag_ids] = [tag.id]

        call!

        expect(recipe.reload.tags).to eq([tag])
      end

      context 'tag being added does not already exist' do
        before { params[:recipe][:tag_names] = ['New Tag'] }

        it 'creates the tag' do
          expect do call! end.to change { Tag.count }.by(1)

          expect(Tag.last.name).to eq('New Tag')
        end

        it 'adds the tag to the recipe' do
          call!

          tag = Tag.last
          expect(recipe.reload.tags).to eq([tag])
        end
      end
    end
  end

  def call!
    RecipeUpdateService.new(recipe, params).call
  end
end
