class CreateTagsAndRecipeTagsTables < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.timestamps null: false
      t.string :name, index: { unique: true }, null: false
      t.string :slug, null: false
    end

    create_table :recipe_tags do |t|
      t.timestamps null: false
      t.references :recipe, index: false, foreign_key: true, null: false
      t.references :tag, index: true, foreign_key: true, null: false
    end

    add_index :recipe_tags, %i[recipe_id tag_id], unique: true
  end
end
