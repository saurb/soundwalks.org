namespace :links do
  namespace :weights do
    desc "Calculates link costs between sounds and tags in the network."
    task :social => :environment do
      #-------------------------#
      # 1. Initialize matrices. #
      #-------------------------#
      puts "Loading sounds and tags."
      
      sounds = Sound.find(:all)
      tags = Tag.find(:all)
      
      #--------------------------------#
      # 2. Construct the votes matrix. #
      #--------------------------------#
      puts "Constructing votes matrix."
      
      votes = Array.new(sounds.size)
      sum_votes = 0
      total_items = 0
      
      sounds.each_with_index do |sound, i|
        sound_tags = sound.tag_counts_on(:tags)
        total = Tagging.count(:conditions => {:taggable_id => sound.id, :taggable_type => 'Sound'})
        
        puts "\tSound #{i + 1} / #{sounds.size}: #{sound_tags} tags, #{total} taggings."
        
        votes[i] = []
        
        sound_tags.each_with_index do |tag, j|
          vote = tag.count.to_f / total.to_f
          votes[i].push({:tag_id => tags.index(sound_tags[j]), :value => vote})
          
          sum_votes += vote
          total_items += 1
        end
        
        Settings.links_weights_social = 0.5 * (i.to_f / sounds.size.to_f)
      end
      
      #------------------------------#
      # 3. Update links in database. #
      #------------------------------#
      puts "Updating links in the database."
      
      index = 0
      
      votes.each_with_index do |row, i|
        puts "\tSound #{i + 1} / #{sounds.size}: #{row.size} tags."
        
        row.each_with_index do |cell, j|
          value = -Math.log(cell[:value] / sum_votes)
          
          Link.update_or_create(sounds[i].mds_node, tags[cell[:tag_id]].mds_node, value, nil)
          Link.update_or_create(tags[cell[:tag_id]].mds_node, sounds[i].mds_node, value, nil)
          
          index += 1
          
          Settings.links_weights_social = 0.5 + 0.5 * index.to_f / total_items.to_f
        end
      end
      
      Settings.links_weights_social = 1
    end
  end
end