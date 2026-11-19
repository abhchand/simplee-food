require 'sinatra_helper'

RSpec.describe IngredientGroupingService, type: :service do
  def group(ingredients)
    IngredientGroupingService.new(ingredients).call
  end

  it 'returns each untagged ingredient as its own entry' do
    expect(group(%w[apple banana])).to eq(
      [
        { name: nil, items: [{ id: 0, text: 'apple' }] },
        { name: nil, items: [{ id: 1, text: 'banana' }] }
      ]
    )
  end

  it 'groups tagged ingredients at the position of their first occurrence' do
    ingredients = [
      '[foo] apple',
      'orange',
      '[bar] banana',
      '[foo] pear',
      'cactus'
    ]

    expect(group(ingredients)).to eq(
      [
        {
          name: 'foo',
          items: [{ id: 0, text: 'apple' }, { id: 3, text: 'pear' }]
        },
        { name: nil, items: [{ id: 1, text: 'orange' }] },
        { name: 'bar', items: [{ id: 2, text: 'banana' }] },
        { name: nil, items: [{ id: 4, text: 'cactus' }] }
      ]
    )
  end

  it 'matches tags case-insensitively, using the first spelling as heading' do
    expect(group(['[Sauce] soy', '[SAUCE] vinegar'])).to eq(
      [
        {
          name: 'Sauce',
          items: [{ id: 0, text: 'soy' }, { id: 1, text: 'vinegar' }]
        }
      ]
    )
  end

  it 'strips whitespace around the tag and the ingredient text' do
    expect(group(['  [ sauce ]   soy  '])).to eq(
      [{ name: 'sauce', items: [{ id: 0, text: 'soy' }] }]
    )
  end

  it 'treats an empty tag as untagged and keeps the original text' do
    expect(group(['[] salt', '[  ] pepper'])).to eq(
      [
        { name: nil, items: [{ id: 0, text: '[] salt' }] },
        { name: nil, items: [{ id: 1, text: '[  ] pepper' }] }
      ]
    )
  end

  it 'does not treat brackets after the start as a tag' do
    expect(group(['salt [optional]'])).to eq(
      [{ name: nil, items: [{ id: 0, text: 'salt [optional]' }] }]
    )
  end

  it 'returns an empty list for empty or nil ingredients' do
    expect(group([])).to eq([])
    expect(group(nil)).to eq([])
  end
end
