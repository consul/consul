class CreateMachineLearningJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :machine_learning_jobs do |t|
      t.datetime :started_at
      t.datetime :finished_at
      t.string :script
      t.integer :pid
      t.string :error
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
