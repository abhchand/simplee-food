# Scrapes a website URL for embedded JSON-LD Recipe data.
#
# Specifically, we look for data of @type `Recipe`, which we expect to conform
# to the [schema.org Recipe specification](https://schema.org/Recipe).
#
# The data should be embedded in one or more `<script>` tags with
# `type="application/ld+json"`.

require 'open-uri'
require 'nokogiri'
require 'json/ld'
require 'json'

module RecipeImport
  class ScrapingService
    def initialize(url)
      @url = url
    end

    # Returns all embedded Recipes within a given site
    # @return Array<Hash>
    def call
      [].tap do |json_ld_recipes|
        each_recipe { |json| json_ld_recipes << json }
      end
    end

    private

    def each_recipe(&block)
      scripts.each do |script_tag|
        begin
          data = JSON.parse(script_tag.content)
        rescue JSON::ParserError => e
          next
        end

        # JSON-LD can be a single object or an array of objects, so we flatten it
        [data].flatten.each do |entry|
          # Check if the entry is a Recipe
          if entry['@type'] == 'Recipe'
            yield(entry)
          elsif entry['@type'].is_a?(Array) && entry['@type'].include?('Recipe')
            yield(entry)
          elsif entry['@graph']
            # If there's a @graph, iterate through its items
            entry['@graph'].each do |item|
              yield(item) if item['@type'] == 'Recipe'
            end
          end
        end
      end
    end

    def scripts
      @scripts ||=
        begin
          html_content = URI.open(@url).read
          doc = Nokogiri.HTML(html_content)
          doc.css('script[type="application/ld+json"]')
        end
    end
  end
end
