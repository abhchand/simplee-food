require 'sinatra_helper'

RSpec.describe RecipeImport::ParsingService, type: :service do
  include FixtureHelpers

  let(:json) { { '@type' => 'Recipe' } }

  describe '#call' do
    describe 'image' do
      let(:url) { 'https://example.com/image.jpg' }

      before do
        # Mock above URL to fetch a local fixture image
        data = File.read(fixture_path_for('atlanta-skyline.png'))
        allow(URI).to receive(:open).with(url) { double(read: data) }
      end

      it 'parses simple text' do
        json['image'] = url

        result = call[:image]
        expect(result[:filename]).to eq(Digest::MD5.hexdigest(url))
        expect(result[:tempfile]).to_not be_nil
        expect(result[:type]).to eq('image/png')
      end

      it 'parses an array of text' do
        json['image'] = [url, 'http://test.com/foo.svg']

        result = call[:image]
        expect(result[:filename]).to eq(Digest::MD5.hexdigest(url))
        expect(result[:tempfile]).to_not be_nil
        expect(result[:type]).to eq('image/png')
      end

      it 'parses an ImageObject' do
        json['image'] = { '@type' => 'ImageObject', 'url' => url }

        result = call[:image]
        expect(result[:filename]).to eq(Digest::MD5.hexdigest(url))
        expect(result[:tempfile]).to_not be_nil
        expect(result[:type]).to eq('image/png')
      end

      it 'parses a list of ImageObjects' do
        json['image'] = [
          { '@type' => 'ImageObject', 'url' => url },
          { '@type' => 'ImageObject', 'url' => 'http://test.com/foo.svg' }
        ]

        result = call[:image]
        expect(result[:filename]).to eq(Digest::MD5.hexdigest(url))
        expect(result[:tempfile]).to_not be_nil
        expect(result[:type]).to eq('image/png')
      end

      context 'image is not present' do
        it 'returns nil' do
          expect(call[:image]).to be_nil
        end
      end
    end

    describe 'parsing ingredients' do
      it 'returns the recipeIngredient' do
        json['recipeIngredient'] = %w[a b]

        expect(call[:ingredients]).to eq(%w[a b])
      end

      context 'ingredients are not present' do
        it 'returns nil' do
          expect(call[:ingredients]).to be_nil
        end
      end
    end

    describe 'parsing instructions' do
      it 'parses simple text' do
        json['recipeInstructions'] = 'Step A'

        expect(call[:instructions]).to eq(['Step A'])
      end

      it 'parses a list of HowToSteps' do
        json['recipeInstructions'] = [
          { '@type' => 'HowToStep', 'text' => 'Step A' },
          { '@type' => 'HowToStep', 'text' => 'Step B' }
        ]

        expect(call[:instructions]).to eq(['Step A', 'Step B'])
      end

      it 'parses a list of HowToSections' do
        json['recipeInstructions'] = [
          {
            '@type' => 'HowToSection',
            'name' => 'Preparation',
            'itemListElement' => [
              { '@type' => 'HowToStep', 'text' => 'Step A' },
              { '@type' => 'HowToStep', 'text' => 'Step B' }
            ]
          },
          {
            '@type' => 'HowToSection',
            'name' => 'Preparation',
            'itemListElement' => [
              { '@type' => 'HowToStep', 'text' => 'Step C' }
            ]
          }
        ]

        expect(call[:instructions]).to eq(['Step A', 'Step B', 'Step C'])
      end

      context 'instructions are not present' do
        it 'returns nil' do
          expect(call[:instructions]).to be_nil
        end
      end
    end

    describe 'parsing name' do
      it 'parses simple text' do
        json['name'] = 'foo'

        expect(call[:name]).to eq('foo')
      end

      context 'name is not present' do
        it 'returns a default value' do
          expect(call[:name]).to eq('New Recipe')
        end
      end
    end

    describe 'parsing serving size' do
      it 'parses simple text' do
        json['recipeYield'] = 'abc'

        expect(call[:serving_size]).to eq('abc')
      end

      it 'parses an array of text' do
        json['recipeYield'] = %w[abc def]

        expect(call[:serving_size]).to eq('abc')
      end

      it 'parses a QuantitativeValue with an integer value' do
        json['recipeYield'] = {
          '@type' => 'QuantitativeValue',
          'unitText' => 'bowls',
          'value' => 2
        }

        expect(call[:serving_size]).to eq('2 bowls')
      end

      it 'parses a QuantitativeValue with an string value' do
        json['recipeYield'] = {
          '@type' => 'QuantitativeValue',
          'unitText' => 'bowls',
          'value' => '2'
        }

        expect(call[:serving_size]).to eq('2 bowls')
      end

      context 'serving size is not present' do
        it 'returns nil' do
          expect(call[:serving_size]).to be_nil
        end
      end
    end

    describe 'parsing source url' do
      let(:url) { 'https://example.com/foo' }

      it 'parses the url key' do
        json['url'] = url

        expect(call[:source_url]).to eq(url)
      end

      context 'url key is not present' do
        before { json['url'] = nil }

        it 'parses mainEntityOfPage as simple text' do
          json['mainEntityOfPage'] = url

          expect(call[:source_url]).to eq(url)
        end

        it 'parses mainEntityOfPage as a WebPage object' do
          json['mainEntityOfPage'] = { '@type' => 'WebPage', '@id' => url }

          expect(call[:source_url]).to eq(url)
        end

        it 'parses mainEntityOfPage as a WebPage object with array @type' do
          json['mainEntityOfPage'] = {
            '@type' => %w[WebPage Foo],
            '@id' => url
          }

          expect(call[:source_url]).to eq(url)
        end
      end

      context 'no source url is available' do
        it 'returns nil' do
          expect(call[:source_url]).to be_nil
        end
      end
    end
  end

  def call
    RecipeImport::ParsingService.new(json).call
  end
end
