class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.references :sound
      t.string :feature_type
      t.text :trajectory
      
      t.timestamps
    end
  end

  def self.down
    drop_table :features
  end
end
