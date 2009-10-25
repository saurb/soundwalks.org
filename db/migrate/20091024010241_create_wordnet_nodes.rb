class CreateWordnetNodes < ActiveRecord::Migration
  def self.up
    create_table :wordnet_nodes do |t|
      t.integer :synset_key
      t.integer :frequency
      t.float :information
      t.boolean :root
      t.string :pos
    end
    
    add_index :wordnet_nodes, :synset_key
    add_index :wordnet_nodes, :frequency
    add_index :wordnet_nodes, :information
    add_index :wordnet_nodes, :root
    add_index :wordnet_nodes, :pos
  end

  def self.down
    drop_table :wordnet_nodes
  end
end
