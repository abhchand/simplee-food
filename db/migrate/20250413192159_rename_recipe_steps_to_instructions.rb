class RenameRecipeStepsToInstructions < ActiveRecord::Migration[5.0]
  def change
    rename_column :recipes, :steps, :instructions
  end
end
