namespace :links do
  namespace :weights do
    desc "Calculates link costs between sounds and tags in the network."    
    task :social => :environment do
      puts "Loading sounds."
      sounds = Sound.find(:all)
      puts "Loading tags."
      tags = Tag.find(:all)
      
      votes = Array.new(sounds.size, [])
      
      # Compute log-probability for each link.
      sum_votes = 0
      total_items = 0
      
      puts "Loading votes."
      sounds.each_with_index do |sound, i|
        puts "\tSound #{i} / #{sounds.size}"
        sound_tags = sound.tag_counts_on(:tags)
        total = sound.taggings.collect{|tagging| tagging.tagger}.uniq.size
        
        sound_tags.each_with_index do |tag, j|
          vote = tag.count.to_f / total.to_f
          votes[i].push({:tag_id => tags.index(sound_tags[j]), :value => vote})
          sum_votes += vote
          total_items += 1
        end
        
        Settings.links_weights_social = 0.5 * (i.to_f / sounds.size.to_f)
      end
      
      # Update links in database.
      index = 0
      
      puts "Updating links."
      votes.each_with_index do |vote, i|
        puts "\tSound #{i} / #{sounds.size}"
        
        vote.each_with_index do |cell, j|
          puts "\t\tTag #{cell[:tag_id]}"
          value = -Math.log(cell[:value] / sum_votes)
          
          Link.update_or_create(sounds[i], tags[cell[:tag_id]], value, nil)
          Link.update_or_create(tags[cell[:tag_id]], sounds[i], value, nil)
          
          index += 1
          
          Settings.links_weights_social = 0.5 + 0.5 * index.to_f / total_items.to_f
        end
      end
      
      Settings.links_weights_social = 1
    end
  end
end