class AlterLinksForMds < ActiveRecord::Migration
  def self.up
    remove_column :links, :first_type
    remove_column :links, :second_type
  end

  def self.down
    add_column :links, :first_type, :string
    add_column :links, :second_type, :string
  end
end
