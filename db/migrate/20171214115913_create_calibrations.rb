class CreateCalibrations < ActiveRecord::Migration
  def change
    create_table :calibrations do |t|
      t.boolean :calibrated, default: :false
      t.boolean :ongoing, default: :false
      t.integer :records
      t.float :result
      t.string :algorithm_class
      t.boolean :pause, default: false
      t.boolean :outcome, default: false
      t.integer :iterations, default: 1
      t.integer :current_iteration, default: 1
      t.timestamps null: false
    end
  end
end
