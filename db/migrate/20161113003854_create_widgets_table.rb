class CreateWidgetsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :widgets do |t|
      t.timestamps null: false
      t.string :name
    end
  end
end
