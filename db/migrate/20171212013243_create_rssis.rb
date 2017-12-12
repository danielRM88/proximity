class CreateRssis < ActiveRecord::Migration
  def change
    create_table :rssis do |t|
      t.integer :value
      t.timestamps null: false
    end
  end
end
