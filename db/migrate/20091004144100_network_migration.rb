Infinity = 1.0 / 0.0

class NetworkMigration < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :first_id
      t.integer :second_id
      t.string :first_type
      t.string :second_type
      
      t.column :cost, :float, :default => Infinity
      t.column :distance, :float, :default => Infinity
      
      t.column :context, :string
      
      t.timestamps
    end
    
    add_index :links, :first_id
    add_index :links, :second_id
    add_index :links, [:first_id, :second_id]
    add_index :links, :cost
    add_index :links, [:first_id, :cost]
  end
  
  def self.down
    drop_table :links
  end
end
