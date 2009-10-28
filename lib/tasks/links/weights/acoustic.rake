namespace :links do
  namespace :weights do
    desc "Calculates link costs between sounds in the network."
    task :old_acoustic => :environment do      
      sounds = Sound.find(:all)
      sound_ids = sounds.collect{|sound| sound.id}
      log_probability = Matrix.rows(Array.new(sounds.size) {Array.new(sounds.size) {Infinity}})
      comparators = Array.new(sounds.size, nil)
      
      total_comparisons = (sounds.size * sounds.size) / 2
      comparison_index = 0
      
      puts "Computing similarities."
      # Compute log-probabilities for link costs.
      for i in 0...sounds.size
        puts "\tSound #{i} / #{sounds.size - 1}"
        comparators[i] = sounds[i].get_comparator if (comparators[i] == nil)
        
        for j in i...sounds.size
          puts "\t\tSound #{j} / #{sounds.size - 1}"
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
          
          comparison_index += 1
          Settings.links_weights_acoustic = 0.5 * (comparison_index.to_f / total_comparisons.to_f)
        end
      end
    
      puts "Creating normalized affinity matrix."
      # Compute log-scale normalized distance matrix.
      affinity = normalize_affinity(log_probability)
      
      link_index = 0
      
      puts "Updating links."
      # Update link costs.
      for i in 0...affinity.row_size
        puts "\tSound #{i} / #{affinity.row_size - 1}"
        
        for j in i...affinity.column_size
          if !affinity[i, j].nan? && (affinity[i, j] != Infinity) && (affinity[i, j] != -Infinity)
            Link.update_or_create(sounds[i], sounds[j], affinity[i, j], nil)
            Link.update_or_create(sounds[j], sounds[i], affinity[i, j], nil)
          end
          
          link_index += 1
          
          Settings.links_weights_acoustic = 0.5 + 0.5 * (link_index.to_f / total_comparisons.to_f)
        end
      end
      
      Settings.links_weights_acoustic = 1
    end
    
    task :acoustic => :environment do
      puts "Loading all sounds."
      sounds = Sound.find(:all)
      comparisons = Array.new(sounds.size)
      comparators = Array.new(sounds.size, nil)
      self_comparison = Array.new(sounds.size, nil)
      total_comparisons = 0
      
      #-------------------------------------------#
      # 1. Find which sounds need to be compared. #
      #-------------------------------------------#
      puts "Finding which sounds need to be compared."
      for i in 0...sounds.size
        puts "\tSound #{i + 1} / #{sounds.size}"
        
        comparisons[i] = []
        
        for j in i...sounds.size
          link = Link.find(:first, :conditions => {:first_id => sounds[i].id, :second_id => sounds[j].id, :first_type => 'Sound', :second_type => 'Sound'})
          comparisons[i].push j if link == nil || link.cost == nil
          total_comparisons += 1
        end
      end
      
      #------------------------------------------------#
      # 2. Compare them and add links to the database. #
      #------------------------------------------------#
      puts "Comparing sounds."
      
      comparison_index = 0
      
      comparisons.each_with_index do |sounds_to_compare, i|
        if sounds_to_compare.size > 0
          puts "\tSound #{i + 1} / #{comparisons.size}"
          comparators[i] = sounds[i].get_comparator if comparators[i] == nil
          self_comparison[i] = comparators[i].compare(comparators[i]) if self_comparison[i] == nil
          
          sounds_to_compare.each_with_index do |j, index|
            puts "\t\tSound #{j + 1} (#{index + 1} / #{sounds_to_compare.size})"
            comparators[j] = sounds[j].get_comparator if (comparators[j] == nil)
            self_comparison[j] = comparators[j].compare(comparators[j]) if self_comparison[j] == nil
            
            i_to_j = comparators[i].compare(comparators[j])
            j_to_i = comparators[i].compare(comparators[j])
            
            value = self_comparison[i] + self_comparison[j] - i_to_j - j_to_i
            
            if !value.nan? && value != Infinity && value != -Infinity
              Link.update_or_create(sounds[i], sounds[j], value, nil)
              Link.update_or_create(sounds[j], sounds[i], value, nil)
            end
            
            comparison_index += 1
            
            Settings.links_weights_acoustic = comparison_index.to_f / total_comparisons.to_f
          end
        end
      end
      
      Settings.links_weights_acoustic = 1
    end
  end
end