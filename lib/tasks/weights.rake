namespace :links do
  namespace :weights do
    #---------------------------------------------------------#
    # links:weights:acoustic: Compute sound-to-sound weights. #
    #---------------------------------------------------------#
    desc "Calculates link costs between sounds in the network."
    
    task :acoustic => :environment do
      Settings.links_weights_acoustic = true
      
      sounds = Sound.find(:all)
      sound_ids = sounds.collect{|sound| sound.id}
      log_probability = Matrix.rows(Array.new(sounds.size) {Array.new(sounds.size) {Infinity}})
      comparators = Array.new(sounds.size, nil)
    
      puts "Computing similarities."
      # Compute log-probabilities for link costs.
      for i in 0...sounds.size
        puts "\t#{i}"
      
        comparators[i] = sounds[i].get_comparator if (comparators[i] == nil)
        
        for j in i...sounds.size
          comparators[j] = sounds[j].get_comparator if (comparators[j] == nil)
        
          value = comparators[i].compare(comparators[j])
        
          if !value.nan?
            log_probability[i, j] = value
            log_probability[j, i] = value
          else
            value = Math.log(0)
            log_probability[i, j] = value
            log_probability[j, i] = value
          end
        end
      end
    
      puts "Creating normalizd affinity matrix."
      # Compute log-scale normalized distance matrix.
      affinity = normalize_affinity(log_probability)
    
      puts "Updating links."
      # Update link costs.
      for i in 0...affinity.row_size
        puts "\t#{i}"
      
        for j in i...affinity.column_size
          if !affinity[i, j].nan? && (affinity[i, j] != Infinity) && (affinity[i, j] != -Infinity)
            update_or_create_link(sounds[i], sounds[j], affinity[i, j], nil)
            update_or_create_link(sounds[j], sounds[i], affinity[i, j], nil)
          end
        end
      end
      
      Settings.links_weights_acoustic = false
    end
  
    #-----------------------------------------------------#
    # links:weights:semantic: Compute tag-to-tag weights. #
    #-----------------------------------------------------#
    desc "Calculates link costs between tags in the network."
    
    task :semantic => :environment do
      Settings.links_weights_semantic = true
      
      # TODO: Use WordNet.
      
      Settings.links_weights_semantic = false
    end
  
    #-----------------------------------------------------#
    # links:weights:social: Compute tag-to-sound weights. #
    #-----------------------------------------------------#
    desc "Calculates link costs between sounds and tags in the network."
    
    task :social => :environment do
      Settings.links_weights_social = true
      
      @sounds = Sound.find(:all)
      
      # Compute log-probability for each link.
      @sounds.each do |sound|
        tags = sound.tag_counts_on(:tags)
        total = sound.taggings.collect{|tagging| tagging.tagger}.uniq.size
        
        tags.each do |tag|
          value = -Math.log(tag.count.to_f / total.to_f)
          
          update_or_create_link(sound, tag, value, nil)
          update_or_create_link(tag, sound, value, nil)
        end
      end
      
      Settings.links_weights_social = false
    end
  end
end