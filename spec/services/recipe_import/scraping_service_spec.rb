require 'sinatra_helper'

RSpec.describe RecipeImport::ScrapingService, type: :service do
  include RecipeImportHelpers

  let(:url) { 'http://example.com' }

  describe '#call' do
    it 'scrapes a recipe from the site' do
      data = { '@type' => 'Recipe', 'foo' => 'bar' }
      mock_site!(data)

      expect(call).to eq([data])
    end

    it 'gracefully ignores non-Recipe types' do
      data = { '@type' => 'Bookmark', 'foo' => 'bar' }
      mock_site!(data)

      expect(call).to eq([])
    end

    it 'handles the @type being an array' do
      data = { '@type' => %w[Recipe Bookmark], 'foo' => 'bar' }
      mock_site!(data)

      expect(call).to eq([data])
    end

    context 'multiple Recipes exist under a script tag' do
      it 'scrapes all recipes from the site' do
        data = [
          { '@type' => 'Recipe', 'foo' => 'bar' },
          { '@type' => 'Recipe', 'cat' => 'dog' }
        ]
        mock_site!(data)

        expect(call).to eq(data)
      end

      it 'gracefully ignores non-Recipe types' do
        data = [
          { '@type' => 'Recipe', 'foo' => 'bar' },
          { '@type' => 'Recipe', 'cat' => 'dog' },
          { '@type' => 'Bookmark', 'abc' => '123' }
        ]
        mock_site!(data)

        expect(call).to eq(data[0..1])
      end
    end

    context 'a @graph is specified' do
      it 'parses each item of the graph as a Recipe' do
        data = {
          '@graph' => [
            { '@type' => 'Recipe', 'foo' => 'bar' },
            { '@type' => 'Recipe', 'cat' => 'dog' }
          ]
        }
        mock_site!(data)

        expect(call).to eq(data['@graph'])
      end

      it 'gracefully ignores non-Recipe types' do
        data = {
          '@graph' => [
            { '@type' => 'Recipe', 'foo' => 'bar' },
            { '@type' => 'Recipe', 'cat' => 'dog' },
            { '@type' => 'Bookmark', 'abc' => '123' }
          ]
        }
        mock_site!(data)

        expect(call).to eq(data['@graph'][0..1])
      end
    end

    context 'multiple <script> tags with JSONLD data exist on the page' do
      it 'scrapes all recipes from the site' do
        data = [{ '@type' => 'Recipe', 'foo' => 'bar' }]
        other_data = [{ '@type' => 'Recipe', 'cat' => 'dog' }]

        mock_site!(data, other_data)

        expect(call).to eq(data.concat(other_data))
      end

      it 'gracefully ignores non-Recipe types' do
        data = [
          { '@type' => 'Recipe', 'foo' => 'bar' },
          { '@type' => 'Bookmark', 'abc' => '123' }
        ]
        other_data = [{ '@type' => 'Recipe', 'cat' => 'dog' }]

        mock_site!(data, other_data)

        expect(call).to eq([data[0]].concat(other_data))
      end
    end

    context '<script> tag does not exist' do
      it 'gracefully returns []' do
        html = '<html><body>boo</body></html>'
        allow(URI).to receive(:open) { double(read: html) }

        expect(call).to eq([])
      end
    end

    context '<script> tag is empty' do
      it 'gracefully returns []' do
        mock_site!('')

        expect(call).to eq([])
      end
    end

    context '<script> tag contains invalid JSON' do
      it 'gracefully returns []' do
        mock_site!('[')

        expect(call).to eq([])
      end

      it 'still parses other scripts' do
        data = { '@type' => 'Recipe', 'foo' => 'bar' }
        mock_site!('[', data)

        expect(call).to eq([data])
      end
    end
  end

  def call
    RecipeImport::ScrapingService.new(url).call
  end
end
