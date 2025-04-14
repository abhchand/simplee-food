require 'sinatra_helper'

RSpec.feature 'Editing Recipes', type: :feature do
  include FixtureHelpers

  let!(:recipe) do
    FactoryBot.create(
      :recipe,
      ingredients: %w[apple banana pear],
      instructions: %w[wash chop boil]
    )
  end
  let(:user) { FactoryBot.create(:user) }

  before do
    log_in(user)
    visit "/recipes/#{recipe.slug}/edit"
  end

  it 'user can navigate to the recipe edit page from the recipe' do
    visit '/recipes'

    # Click on the recipe name
    within(".recipes-index__item[data-name='#{recipe.slug}']") do
      click_link(recipe.name)
    end
    expect(page).to have_current_path("/recipes/#{recipe.slug}")

    # Click on the "edit" button
    page.find('.recipe-title-bar a').click
    expect(page).to have_current_path("/recipes/#{recipe.slug}/edit")
  end

  it 'user can update name, but can not remove it', js: true do
    # Updating name

    expect do
      fill_in('recipe[name]', with: 'New Name')
      click_save!

      expect(page).to have_current_path('/recipes/new-name')
    end.to change { recipe.reload.name }.to('New Name')

    # Clearing name result in a flash error

    visit "/recipes/#{recipe.slug}/edit"

    expect do
      fill_in('recipe[name]', with: '')
      click_save!

      expect(page).to have_current_path("/recipes/#{recipe.slug}/edit")
    end.to_not change { recipe.reload.name }

    expect_flash_message("Name can't be blank")
  end

  it 'user can update and clear `source_url` and `serving_size`', js: true do
    # Updating fields

    expect do
      expect do
        fill_in('recipe[source_url]', with: 'https://my-recipes.com')
        fill_in('recipe[serving_size]', with: '99 cups')
        click_save!

        expect(page).to have_current_path("/recipes/#{recipe.slug}")
      end.to change { recipe.reload.source_url }.to('https://my-recipes.com')
    end.to change { recipe.reload.serving_size }.to('99 cups')

    # Clearing fields

    visit "/recipes/#{recipe.slug}/edit"

    expect do
      expect do
        fill_in('recipe[source_url]', with: '')
        fill_in('recipe[serving_size]', with: '')
        click_save!

        expect(page).to have_current_path("/recipes/#{recipe.slug}")
      end.to change { recipe.reload.source_url }.to(nil)
    end.to change { recipe.reload.serving_size }.to(nil)
  end

  describe 'recipe image', js: true do
    it 'user can add a new image' do
      expect do
        expect do
          select_image('atlanta-skyline.png')

          click_save!
          expect(page).to have_current_path("/recipes/#{recipe.slug}")
        end.to change { recipe.reload.image }.from(nil)
      end.to change { recipe.reload.image_thumbnail }.from(nil)
    end

    it 'user can edit an existing image' do
      # Update image with fake data to simulate some existing image
      recipe.update!(image: 'some-data', image_thumbnail: 'some-other-data')
      visit current_path

      expect do
        expect do
          select_image('atlanta-skyline.png')

          click_save!
          expect(page).to have_current_path("/recipes/#{recipe.slug}")
        end.to change { recipe.reload.image }
      end.to change { recipe.reload.image_thumbnail }
    end
  end

  describe 'ingredients', js: true do
    it 'unless can add, update, and remove ingredients' do
      # Initial list is %w[apple banana pear]
      #
      # We do the following:
      #   * add "strawberry"
      #   * update "apple" to "cherry"
      #   * remove "pear"
      #
      # End list should be %w[cherry banana strawberry]

      within('#recipe-ingredients') do
        click_add_button
        fill_in('recipe[ingredients][3]', with: 'strawberry')

        fill_in('recipe[ingredients][0]', with: 'cherry')

        delete_ingredient(2)

        expect_ingredients_to_be(%w[cherry banana strawberry])
      end
    end

    it 'user can re-order ingredients' do
      # Initial list is %w[apple banana pear]
      #
      # We do the following:
      #   * move "pear" up
      #   * move "apple" down
      #
      # End list should be %w[pear apple bananna]

      within('#recipe-ingredients') do
        move_ingredient_up(2)
        move_ingredient_down(0)

        # Also hit "up" on the top element and "down" on the bottom element
        # to ensure that we have bounds in place, and that it doesn't mess
        # up anything
        move_ingredient_up(0)
        move_ingredient_down(2)

        expect_ingredients_to_be(%w[pear apple banana])
      end
    end

    it 'user can bulk add ingredients' do
      # Initial list is %w[apple banana pear]
      #
      # We bulk add: "strawberry" and "cherry"

      # End list should be %w[apple banana pear strawberry cherry]

      within('#recipe-ingredients') do
        bulk_add("strawberry\ncherry")
        expect_ingredients_to_be(%w[apple banana pear strawberry cherry])
      end
    end
  end

  describe 'instructions', js: true do
    it 'unless can add, update, and remove instructions' do
      # Initial list is %w[wash chop boil]
      #
      # We do the following:
      #   * add "fry"
      #   * update "wash" to "sautee"
      #   * remove "boil"
      #
      # End list should be %w[sautee chop fry]

      within('#recipe-instructions') do
        click_add_button
        fill_in('recipe[instructions][3]', with: 'fry')

        fill_in('recipe[instructions][0]', with: 'sautee')

        delete_instruction(2)

        expect_instructions_to_be(%w[sautee chop fry])
      end
    end

    it 'user can re-order instructions' do
      # Initial list is %w[wash chop boil]
      #
      # We do the following:
      #   * move "boil" up
      #   * move "wash" down
      #
      # End list should be %w[boil wash chop]

      within('#recipe-instructions') do
        move_instruction_up(2)
        move_instruction_down(0)

        # Also hit "up" on the top element and "down" on the bottom element
        # to ensure that we have bounds in place, and that it doesn't mess
        # up anything
        move_instruction_up(0)
        move_instruction_down(2)

        expect_instructions_to_be(%w[boil wash chop])
      end
    end

    it 'user can bulk add instructions' do
      # Initial list is %w[wash chop boil]
      #
      # We bulk add: "fry" and "sautee"

      # End list should be %w[wash chop boil fry sautee]

      within('#recipe-instructions') do
        bulk_add("fry\nsautee")
        expect_instructions_to_be(%w[wash chop boil fry sautee])
      end
    end
  end

  describe 'editing tags', js: true do
    let(:tags) do
      [
        FactoryBot.create(:tag, name: 'sky blue'),
        FactoryBot.create(:tag, name: 'forest green')
      ]
    end

    before do
      # Apply `sky blue` to the recipe
      FactoryBot.create(:recipe_tag, recipe: recipe, tag: tags[0])

      visit current_path
    end

    it 'user can add and remove tags' do
      # First tag should be checked
      expect(page).to have_checked_field("recipe_tag_ids_#{tags[0].slug}")
      expect(page).to have_unchecked_field("recipe_tag_ids_#{tags[1].slug}")

      expect do
        # Uncheck first, check the second
        uncheck("recipe_tag_ids_#{tags[0].slug}")
        check("recipe_tag_ids_#{tags[1].slug}")

        click_save!

        expect(page).to have_current_path("/recipes/#{recipe.slug}")
      end.to change { recipe.reload.tags }.from([tags[0]]).to([tags[1]])

      # First tag should no longer exist since no recipe uses it
      expect(Tag.find_by_id(tags[0].id)).to be_nil

      # Frontend should display updated tag
      visit "/recipes/#{recipe.slug}/edit"
      expect(page).to_not have_selector("#recipe_tag_ids_#{tags[0].slug}")
      expect(page).to have_checked_field("recipe_tag_ids_#{tags[1].slug}")
    end

    it 'user can create a new tag' do
      expect do
        # Create a new tag
        page.accept_prompt(with: 'cherry red') { click_button('add new tag') }

        click_save!

        expect(page).to have_current_path("/recipes/#{recipe.slug}")
      end.to change { recipe.reload.tags.count }.from(1).to(2)

      # New tag should have been added
      new_tag = Tag.find_by_name!('cherry red')
      expect(recipe.tags).to eq([tags[0], new_tag])

      # Second (unchecked) tag should no longer exist since no recipe uses it
      expect(Tag.find_by_id(tags[1].id)).to be_nil

      # Frontend should display updated tag list
      visit "/recipes/#{recipe.slug}/edit"
      expect(page).to have_checked_field("recipe_tag_ids_#{tags[0].slug}")
      expect(page).to_not have_selector("#recipe_tag_ids_#{tags[1].slug}")
      expect(page).to have_checked_field("recipe_tag_ids_#{new_tag.slug}")
    end
  end

  it 'user can also submit using the `save` button at top of page', js: true do
    expect do
      fill_in('recipe[serving_size]', with: '99 cups')

      # Click top save button
      page.all('.recipes-edit__save-btn')[0].click

      expect(page).to have_current_path("/recipes/#{recipe.slug}")
    end.to change { recipe.reload.serving_size }.to('99 cups')
  end

  it 'user can cancel changes without saving' do
    fill_in('recipe[serving_size]', with: '99 cups')

    expect do
      click_link('cancel')

      expect(page).to have_current_path("/recipes/#{recipe.slug}")
    end.to_not change { recipe.reload.attributes }
  end

  def click_add_button
    page.find('.recipes-edit__add-sortable-item-btn').click
  end

  def bulk_add(text)
    # Click "bulk add"
    page.find('.recipes-edit__bulk-add-sortable-item-btn').click

    page.find('.modal-textarea').set(text)

    # Click "add" (submit)
    page.find('.recipes-edit__bulk-add-sortable-item-open-btn').click
  end

  def click_save!
    # There's 2 save buttons - click the bottom one by default
    page.all('.recipes-edit__save-btn')[1].click
  end

  def delete_ingredient(idx)
    input = page.find("input[name='recipe[ingredients][#{idx}]']")
    parent = input.find(:xpath, '..')
    parent.all('button')[2].click
  end

  def delete_instruction(idx)
    textarea = page.find("textarea[name='recipe[instructions][#{idx}]']")
    parent = textarea.find(:xpath, '..')
    parent.all('button')[2].click
  end

  def expect_ingredients_to_be(array)
    expect(
      page.all('.recipes-edit__sortable-list-row input').map(&:value)
    ).to eq(array)
  end

  def expect_instructions_to_be(array)
    expect(
      page.all('.recipes-edit__sortable-list-row textarea').map(&:value)
    ).to eq(array)
  end

  def move_ingredient_down(idx)
    input = page.find("input[name='recipe[ingredients][#{idx}]']")
    parent = input.find(:xpath, '..')
    parent.all('button')[1].click
  end

  def move_ingredient_up(idx)
    input = page.find("input[name='recipe[ingredients][#{idx}]']")
    parent = input.find(:xpath, '..')
    parent.all('button')[0].click
  end

  def move_instruction_down(idx)
    textarea = page.find("textarea[name='recipe[instructions][#{idx}]']")
    parent = textarea.find(:xpath, '..')
    parent.all('button')[1].click
  end

  def move_instruction_up(idx)
    textarea = page.find("textarea[name='recipe[instructions][#{idx}]']")
    parent = textarea.find(:xpath, '..')
    parent.all('button')[0].click
  end

  def select_image(fixture_name)
    attach_file('recipe[image]', fixture_path_for(fixture_name), visible: false)
  end
end
