class AddTitlesToSounds < ActiveRecord::Migration
  def self.up
    add_column :sounds, :title, :string
  end

  def self.down
    remove_column :sounds, :title
  end
end
