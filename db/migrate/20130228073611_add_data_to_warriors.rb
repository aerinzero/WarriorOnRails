class AddDataToWarriors < ActiveRecord::Migration
  def change
    add_column :warriors, :data, :text
  end
end
