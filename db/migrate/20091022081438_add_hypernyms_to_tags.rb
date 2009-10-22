class AddHypernymsToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :hypernym, :integer
  end

  def self.down
    remove_column :tags, :hypernym
  end
end
