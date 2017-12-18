class CreateData < ActiveRecord::Migration
  def change
    create_table :training_data do |t|
      t.integer :value
      t.boolean :outcome, default: false
      t.integer :iteration, default: 1
      t.timestamps null: false
    end
  end
end
