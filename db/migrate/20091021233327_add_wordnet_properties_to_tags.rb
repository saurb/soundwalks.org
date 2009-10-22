class AddWordnetPropertiesToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :frequency, :integer
    add_column :tags, :part_of_speech, :string
    add_column :tags, :synset_id, :integer
    add_column :tags, :word_sense, :integer
    add_column :tags, :synset_label, :string
  end

  def self.down
    remove_column :tags, :frequency
    remove_column :tags, :part_of_speech
    remove_column :tags, :synset_id
    remove_column :tags, :word_sense
    remove_column :tags, :synset_label
  end
end
