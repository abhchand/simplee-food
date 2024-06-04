class CreateUsersTable < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.timestamps null: false
      # Unique index added manually below
      t.string :name, null: false, index: false
      t.string :password, null: false
    end

    add_index :users, :name, unique: true
  end
end
