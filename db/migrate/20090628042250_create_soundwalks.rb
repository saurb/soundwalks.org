class CreateSoundwalks < ActiveRecord::Migration
  def self.up
    create_table :soundwalks do |t|
      t.string :filename
      t.string :content_type
      t.integer :size
      
      t.string :title
      t.text :description
      t.text :locations
      
      t.decimal :lat, :precision => 15, :scale => 12
      t.decimal :lng, :precision => 15, :scale => 12
      
      t.references :user
      
      t.timestamps
    end
  end

  def self.down
    drop_table :soundwalks
  end
end
