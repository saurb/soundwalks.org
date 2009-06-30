class CreateSoundwalks < ActiveRecord::Migration
  def self.up
    create_table :soundwalks do |t|
      t.string :title
      t.text :description
      t.text :locations
      
      t.decimal :lat
      t.decimal :lng
      
      t.references :user
      
      t.timestamps
    end
  end

  def self.down
    drop_table :soundwalks
  end
end
