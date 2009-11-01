namespace :links do
  namespace :weights do
    desc "Calculates link costs between sounds and tags in the network."
    task :social => :environment do
      #--------------------------#
      # 1. Load sounds and tags. #
      #--------------------------#
      puts "1. Loading sounds and tags."
      
      sounds = Sound.find(:all)
      tags = Tag.find(:all)
      
      #--------------------------------#
      # 2. Construct the votes matrix. #
      #--------------------------------#
      puts "2. Constructing votes matrix."
      
      votes = Array.new(sounds.size)
      sum_votes = 0
      
      sounds.each_with_index do |sound, i|
        sound_tags = sound.tag_counts_on(:tags)
        total = Tagging.count(:conditions => {:taggable_id => sound.id, :taggable_type => 'Sound'})
        
        puts "\tSound #{i + 1} / #{sounds.size}: #{sound_tags} tags, #{total} taggings."
        
        votes[i] = []
        
        sound_tags.each_with_index do |tag, j|
          vote = tag.count / total.to_f
          votes[i].push({:tag_id => tags.index(sound_tags[j]), :value => vote})
          
          sum_votes += vote
        end
      end
      
      #------------------------------#
      # 3. Update links in database. #
      #------------------------------#
      puts "3. Updating links in the database."
      
      votes.each_with_index do |row, i|
        puts "\tSound #{i + 1} / #{sounds.size}: #{row.size} tags."
        
        row.each_with_index do |cell, j|
          cost = -Math.log(cell[:value] / sum_votes)
          
          Link.update_or_create(sounds[i].mds_node, tags[cell[:tag_id]].mds_node, cost, nil)
          Link.update_or_create(tags[cell[:tag_id]].mds_node, sounds[i].mds_node, cost, nil)
        end
      end
    end
  end
end