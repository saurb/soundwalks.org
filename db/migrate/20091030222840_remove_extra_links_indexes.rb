class RemoveExtraLinksIndexes < ActiveRecord::Migration
  def self.up
    remove_index :links, :column => :cost
    remove_index :links, :column => [:first_id, :cost]
  end

  def self.down
    add_index :links, :cost
    add_index :links, [:first_id, :cost]
  end
end
