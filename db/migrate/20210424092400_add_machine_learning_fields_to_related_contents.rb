class AddMachineLearningFieldsToRelatedContents < ActiveRecord::Migration[5.2]
  def change
    add_column :related_contents, :machine_learning, :boolean, default: false
    add_column :related_contents, :machine_learning_score, :integer, default: 0
  end
end
