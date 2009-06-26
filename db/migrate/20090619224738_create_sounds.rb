class CreateSounds < ActiveRecord::Migration
  def self.up
    create_table :sounds do |t|
      t.string :filename
      t.integer :samples
      t.integer :sample_rate
      t.integer :frame_size
      t.integer :hop_size
      t.integer :spectrum_size
      t.integer :frames
      t.decimal :frame_length
      t.decimal :hop_length
      
      # New
      t.text :description
      t.decimal :longitude
      t.decimal :latitude
      
      t.text :features
      
      t.timestamp :recorded_at

      t.timestamps
    end
  end

  def self.down
    drop_table :sounds
  end
end
