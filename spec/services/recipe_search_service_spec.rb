require 'sinatra_helper'

RSpec.describe RecipeSearchService, type: :service do
  let!(:recipes) do
    [
      FactoryBot.create(:recipe, name: 'Pasta Salad', created_at: 3.days.ago),
      FactoryBot.create(:recipe, name: 'Pulav', created_at: 2.days.ago),
      FactoryBot.create(:recipe, name: 'Black Bean Soup', created_at: 1.day.ago)
    ]
  end

  let(:params) { Hash.new }
  let(:data) { RecipeSearchService.new(params).call }

  before { stub_const('RecipeSearchService::DEFAULT_PAGE_SIZE', 10) }

  it 'returns all Recipes by default, sorted by recent first' do
    expect(data).to eq(
      'items' => [recipes[2], recipes[1], recipes[0]],
      'first_item' => 1,
      'last_item' => 3,
      'total_items' => 3,
      'current_page' => 1,
      'last_page' => 1,
      'tag' => nil
    )
  end

  context 'a tag is present' do
    let(:tag) { FactoryBot.create(:tag, name: 'vegan') }

    before { recipes[1].add_tag(tag) }

    it 'returns only recipes with the specified tag' do
      params['tag'] = tag.slug

      expect(data).to eq(
        'items' => [recipes[1]],
        'first_item' => 1,
        'last_item' => 1,
        'total_items' => 1,
        'current_page' => 1,
        'last_page' => 1,
        'tag' => tag
      )
    end
  end

  context 'searching' do
    it 'searches by recipe name' do
      params['search'] = 'Pul'

      expect(data).to eq(
        'items' => [recipes[1]],
        'first_item' => 1,
        'last_item' => 1,
        'total_items' => 1,
        'current_page' => 1,
        'last_page' => 1,
        'tag' => nil
      )
    end

    it 'is case insensitive' do
      params['search'] = 'pul'

      expect(data).to eq(
        'items' => [recipes[1]],
        'first_item' => 1,
        'last_item' => 1,
        'total_items' => 1,
        'current_page' => 1,
        'last_page' => 1,
        'tag' => nil
      )
    end

    it 'can search by multiple words at once' do
      params['search'] = 'la s'

      expect(data).to eq(
        'items' => [recipes[2], recipes[0]],
        'first_item' => 1,
        'last_item' => 2,
        'total_items' => 2,
        'current_page' => 1,
        'last_page' => 1,
        'tag' => nil
      )
    end

    it 'gracefully handles empty search strings' do
      params['search'] = ''

      expect(data).to eq(
        'items' => [recipes[2], recipes[1], recipes[0]],
        'first_item' => 1,
        'last_item' => 3,
        'total_items' => 3,
        'current_page' => 1,
        'last_page' => 1,
        'tag' => nil
      )
    end

    it 'gracefully handles no data found' do
      params['search'] = 'xyz'

      expect(data).to eq(
        'items' => [],
        'first_item' => 0,
        'last_item' => 0,
        'total_items' => 0,
        'current_page' => 1,
        'last_page' => 0,
        'tag' => nil
      )
    end
  end

  context 'sorting' do
    it 'can sort by name' do
      params['sort_by'] = 'name'

      expect(data).to eq(
        'items' => [recipes[2], recipes[0], recipes[1]],
        'first_item' => 1,
        'last_item' => 3,
        'total_items' => 3,
        'current_page' => 1,
        'last_page' => 1,
        'tag' => nil
      )
    end
  end

  context 'pagination' do
    before { stub_const('RecipeSearchService::DEFAULT_PAGE_SIZE', 2) }

    it 'paginates the results using the default page size' do
      expect(data).to eq(
        'items' => [recipes[2], recipes[1]],
        'first_item' => 1,
        'last_item' => 2,
        'total_items' => 3,
        'current_page' => 1,
        'last_page' => 2,
        'tag' => nil
      )
    end

    context 'page param is specified' do
      it 'returns the requested page' do
        params['page'] = '2'

        expect(data).to eq(
          'items' => [recipes[0]],
          'first_item' => 3,
          'last_item' => 3,
          'total_items' => 3,
          'current_page' => 2,
          'last_page' => 2,
          'tag' => nil
        )
      end

      it 'ignores negative pages' do
        params['page'] = '-1'

        expect(data).to eq(
          'items' => [recipes[2], recipes[1]],
          'first_item' => 1,
          'last_item' => 2,
          'total_items' => 3,
          'current_page' => 1,
          'last_page' => 2,
          'tag' => nil
        )
      end

      context 'page param is out of bounds' do
        it 'returns the last page' do
          params['page'] = '99'

          expect(data).to eq(
            'items' => [recipes[0]],
            'first_item' => 3,
            'last_item' => 3,
            'total_items' => 3,
            'current_page' => 2,
            'last_page' => 2,
            'tag' => nil
          )
        end
      end
    end

    context 'page_size param is specified' do
      it 'paginates using the requested page size' do
        params['page_size'] = '10'

        expect(data).to eq(
          'items' => [recipes[2], recipes[1], recipes[0]],
          'first_item' => 1,
          'last_item' => 3,
          'total_items' => 3,
          'current_page' => 1,
          'last_page' => 1,
          'tag' => nil
        )
      end

      it 'ignores negative page sizes and falls back on the default' do
        params['page_size'] = '-1'

        expect(data).to eq(
          'items' => [recipes[2], recipes[1]],
          'first_item' => 1,
          'last_item' => 2,
          'total_items' => 3,
          'current_page' => 1,
          'last_page' => 2,
          'tag' => nil
        )
      end
    end
  end
end
