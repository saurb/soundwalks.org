namespace :links do
  namespace :weights do
    desc "Calculates link costs between sounds in the network."
    task :acoustic => :environment do      
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
          Settings.links_weights_acoustic = (i * sounds.size + j).to_f / (sounds.size * sounds.size).to_f
          
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
            Link.update_or_create(sounds[i], sounds[j], affinity[i, j], nil)
            Link.update_or_create(sounds[j], sounds[i], affinity[i, j], nil)
          end
        end
      end
      
      Settings.links_weights_acoustic = 1
    end
  end
end