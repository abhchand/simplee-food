class CreateConfigsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :configs, id: false do |t|
      t.string :key, null: false
      t.string :value, null: false
    end

    add_index :configs, :key, unique: true
  end
end
