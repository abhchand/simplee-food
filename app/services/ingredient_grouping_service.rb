#
# Groups a recipe's ingredients by an optional `[tag]` prefix for display.
#
# e.g. given the ingredients
#
#   ['[foo] apple', 'orange', '[bar] banana', '[foo] pear', 'cactus']
#
# returns
#
#   [
#     { name: 'foo', items: [{ id: 0, text: 'apple' }, { id: 3, text: 'pear' }] },
#     { name: nil, items: [{ id: 1, text: 'orange' }] },
#     { name: 'bar', items: [{ id: 2, text: 'banana' }] },
#     { name: nil, items: [{ id: 4, text: 'cactus' }] }
#   ]
#
class IngredientGroupingService
  # A tag must be the very first thing in the ingredient. Brackets anywhere
  # else (e.g. 'salt [optional]') are treated as part of the ingredient text.
  TAG_REGEX = /\A\s*\[([^\]]*)\]\s*(.*)\z/m

  def initialize(ingredients)
    @ingredients = ingredients || []
  end

  def call
    entries = []
    groups_by_key = {}

    @ingredients.each_with_index do |ingredient, id|
      tag, text = parse(ingredient)

      # Untagged ingredients are each their own entry, which keeps them in
      # their original position relative to everything else.
      if tag.nil?
        entries << { name: nil, items: [{ id: id, text: text }] }
        next
      end

      # A group is placed where its *first* item appears. Subsequent items with
      # the same tag are pulled up into that group rather than starting a new
      # one. Tags are matched case-insensitively, and the heading keeps the
      # spelling of the first occurrence.
      key = tag.downcase
      group = groups_by_key[key]

      if group.nil?
        group = { name: tag, items: [] }
        groups_by_key[key] = group
        entries << group
      end

      # The original index is kept so checkbox ids stay unique and stable.
      group[:items] << { id: id, text: text }
    end

    entries
  end

  private

  # @return [Array] a pair of `[tag, text]`, where `tag` is `nil` if the
  #   ingredient has no (non-blank) tag prefix
  def parse(ingredient)
    match = TAG_REGEX.match(ingredient.to_s)
    tag = match && match[1].strip

    # An empty tag (e.g. '[] salt') is not a group, so leave the text as-is
    return nil, ingredient if tag.nil? || tag.empty?

    [tag, match[2].strip]
  end
end
