class CreateRecipesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.timestamps null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.binary :image
      t.string :serving_size
      t.json :ingredients, default: '[]'
      t.json :steps, default: '[]'
      t.string :source_url
      t.text :notes
    end
  end
end
