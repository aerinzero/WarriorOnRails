class CreateWarriors < ActiveRecord::Migration
  def change
    create_table :warriors do |t|
      t.string :name
      t.text :code
      t.integer :level

      t.timestamps
    end
  end
end