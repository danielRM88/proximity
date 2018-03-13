class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.boolean :actual_seated, default: false
      t.float :prediction_value
      t.boolean :predicted_seated, default: false
      t.string :algorithm_class
      t.string :gender
      t.float :height
      t.float :weight
      t.timestamps null: false
    end
  end
end
