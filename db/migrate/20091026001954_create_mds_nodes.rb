class CreateMdsNodes < ActiveRecord::Migration
  def self.up
    create_table :mds_nodes do |t|
      t.float :x
      t.float :y
      t.float :z
      t.float :w
      
      t.integer :owner_id
      t.string :owner_type
    end
    
    add_index :mds_nodes, :x
    add_index :mds_nodes, :y
    add_index :mds_nodes, :z
    add_index :mds_nodes, :w
  end

  def self.down
    drop_table :mds_nodes
  end
end
