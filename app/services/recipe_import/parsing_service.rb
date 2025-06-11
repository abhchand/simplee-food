# Parses JSON-LD Recipe data according to the
# [schema.org Recipe specification](https://schema.org/Recipe).
#
# The data is returned as a Hash of attributes that can be used to create a
# `Recipe` model instance.

require 'digest'
require 'tempfile'
require 'uri'

module RecipeImport
  class ParsingService
    def initialize(json_ld)
      @json = json_ld
    end

    def call
      ActiveSupport::HashWithIndifferentAccess.new(
        {
          image: image,
          ingredients: ingredients,
          instructions: instructions,
          name: name,
          serving_size: serving_size,
          source_url: source_url
        }.compact
      )
    end

    private

    # Downloads the recipe image url to a local tempfile and returns the
    # `Tempfile` object. Returns `nil` if no URL is present.
    def image
      url = image_url
      return if url.nil?

      data = URI.open(url).read
      filename = Digest::MD5.hexdigest(url)

      tempfile =
        Tempfile
          .new(filename)
          .tap do |f|
            f.binmode
            f.write(data)
            f.flush
          end

      img = MiniMagick::Image.new(tempfile.path)
      mime_type = img.data['mimeType']
      return if mime_type.nil?

      { filename: filename, tempfile: tempfile, type: mime_type }
    end

    # 1. The 'image', which can be a URL or array of URLs
    #   { "image": "https://example.com/image.jpg" }
    #   { "image": ["https://example.com/image.jpg"] }
    #
    # 2. The 'image', which can be of type [`ImageObject`](https://schema.org/ImageObject)
    #    or array of `ImageObject`.
    #   { "image": { "@type": "ImageObject", "url": "https://example.com/image.jpg" } }
    #   { "image": [{ "@type": "ImageObject", "url": "https://example.com/image.jpg" }] }
    def image_url
      img = [@json['image']].flatten.first

      return img if url?(img)

      return unless img.is_a?(Hash) && img['@type'] == 'ImageObject'

      img['url'] if url?(img['url'])
    end

    def ingredients
      @json['recipeIngredient']
    end

    # As per the [schema.org](https://schema.org/Recipe) specification for
    # `Recipe`, the instructions can be derived from the following, in order of
    # precedence:
    #
    # 1. The 'recipeInstructions', which can be simple text
    #   { "recipeInstructions": "Boil water" }
    #
    # 2. The 'recipeInstructions', which can be an array of [`HowToStep`](https://schema.org/HowToStep)
    #   { "recipeInstructions": [{ "@type": "HowToStep", "text": "Boil water" }]}
    #
    # 3. The 'recipeInstructions', which can be an array of [`HowToSection`](https://schema.org/HowToSection)
    #   {
    #     "recipeInstructions": [
    #       {
    #         "@type": "HowToSection",
    #         "name": "Preparation",
    #         "itemListElement": [
    #           { "@type": "HowToStep", "text": "Boil water" }
    #         ]
    #       }
    #     ]
    #   }
    def instructions
      ri = @json['recipeInstructions']

      return [ri] if ri.is_a?(String)

      return unless ri.is_a?(Array)

      types = ri.map { |i| i['@type'] }.uniq
      items =
        case types
        when ['HowToStep']
          ri
        when ['HowToSection']
          ri.map { |i| i['itemListElement'] }.flatten
        else
          return
        end

      items.map { |i| i['text'] }
    end

    def name
      @json['name'] || 'New Recipe'
    end

    # As per the [schema.org](https://schema.org/Recipe) specification for
    # `Recipe`, the serving size can be derived from the following, in order of
    # precedence:
    #
    # 1. The 'recipeYield', which can be text or an array of text
    #   { "recipeYield": "2 bowls" }
    #   { "recipeYield": ["2 bowls"] }
    #
    # 2. The 'recipeYield', which can be a `QuantitativeValue` with a `Number`,
    #    or `Text` for the 'value' key. NOTE: The schema specification also
    #    allows 'value' to be a [StructuredValue](https://schema.org/StructuredValue).
    #    We ignored this case to keep things simple.
    #
    #   { "recipeYield": { "@type": "QuantitativeValue", "unitText": "bowls", "value": 2 }}
    #   { "recipeYield": { "@type": "QuantitativeValue", "unitText": "bowls", "value": "2" }}
    def serving_size
      ry = @json['recipeYield']

      arr = [ry].flatten.compact
      return arr.first if arr.first.is_a?(String)

      if ry.is_a?(Hash) && ry['@type'] == 'QuantitativeValue'
        if [String, Integer].include?(ry['value'].class)
          return "#{ry['value']} #{ry['unitText']}".strip
        end
      end

      nil
    end

    # As per the [schema.org](https://schema.org/Recipe) specification for
    # `Recipe`, the source URL can be derived from the following, in order of
    # precedence:
    #
    # 1. The 'url' key:
    #   { "url": "https://example.com/kale-salad" }
    #
    # 2. The 'mainEntityOfPage' key, which can be a URL string
    #
    #   { "mainEntityOfPage": "https://example.com/kale-salad" }
    #
    # 3. The 'mainEntityOfPage' key, which can be of @type "WebPage".
    #    NOTE: The `@type` can be an array
    #
    #   { "mainEntityOfPage": { "@type": "WebPage", "@id": "https://example.com/kale-salad" } }
    #   { "mainEntityOfPage": { "@type": ["WebPage"], "@id": "https://example.com/kale-salad" } }
    #
    # 4. The '@id' key:
    #   { "@id": "https://example.com/kale-salad" }
    def source_url
      return @json['url'] if url?(@json['url'])
      return @json['mainEntityOfPage'] if url?(@json['mainEntityOfPage'])

      if @json['mainEntityOfPage'].is_a?(Hash)
        meop = @json['mainEntityOfPage']
        types = [meop['@type']].flatten

        return meop['@id'] if types.include?('WebPage') && url?(meop['@id'])
      end

      @json['@id'] if url?(@json['@id'])
    end

    def url?(url)
      url.is_a?(String) && UrlValidationService.new(url).valid?
    end
  end
end
