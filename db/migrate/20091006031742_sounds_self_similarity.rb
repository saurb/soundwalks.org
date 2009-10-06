class SoundsSelfSimilarity < ActiveRecord::Migration
  def self.up
    add_column :sounds, :self_similarity, :float, :default => 0
  end

  def self.down
    remove_column :sounds, :self_similarity
  end
end
