namespace :tags do
  #-----------------------------------------------------------------------------------------#
  # tags:frequencies: Updates frequency counts for all tags in the database using a corpus. #
  #-----------------------------------------------------------------------------------------#  
  desc "Updates frequency counts for all tags in the database using a corpus."
  
  task :frequencies => :environment do
    Settings.tags_frequencies = 1
    
    tags = Tag.find(:all)
    tag_ids = []
    tag_pos = []
    tags.each do |tag|
      tag_ids.push tag.synset_id
      tag_pos.push tag.part_of_speech
    end
    
    file = File.open("#{RAILS_ROOT}/data/ic-bnc-add1.dat", 'r')
    tag_count = 0
    
    file.each_line do |line|
      elements = line.split(' ')
      if elements.size > 1
        id = elements.first.gsub(/[a-z|A-Z]/, '').to_i + 100000000
        
        part_of_speech = elements.first.gsub(/[0-9]/, '')
        part_of_speech = 'noun' if part_of_speech == 'n'
        part_of_speech = 'verb' if part_of_speech == 'v'
        part_of_speech = 'adjective' if part_of_speech == 'a'
        part_of_speech = 'adverb' if part_of_speech == 'r'
        
        frequency = elements.second.to_i   
        
        update_tags = tags.reject {|tag| !(tag.synset_id == id and tag.part_of_speech == part_of_speech)}
        
        update_tags.each do |tag|
          tag.frequency = frequency
          tag.save
          tag_count += 1
          puts "#{tag_count}: #{tag.name}: #{frequency}"
        end
      end
    end
    
    file.close
  end
end
