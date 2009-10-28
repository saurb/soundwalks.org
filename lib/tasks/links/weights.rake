Infinity = 1.0 / 0.0

namespace :links do
  namespace :weights do
    #---------------------------------------------------------#
    # links:weights:acoustic: Compute sound-to-sound weights. #
    #---------------------------------------------------------#
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
  
    #-----------------------------------------------------#
    # links:weights:semantic: Compute tag-to-tag weights. #
    #-----------------------------------------------------#
    desc "Calculates link costs between tags in the network."
    
    task :semantic => :environment do     
      include WordnetHelper
       
      # TODO: Use WordNet.
      tags = Tag.find(:all)
      
      distances = Matrix.rows(Array.new(tags.size){Array.new(tags.size, Infinity)})
      
      total_computations = (tags.size * tags.size) / 2
      
      max_distance = 0
      
      for i in 0...tags.size
        for j in i...tags.size
          distances[i, j] = jcn_distance(tags[i].name, tags[j].name)
          max_distance = distances[i, j] if distances[i, j] > max_distance and distances[i, j] < Infinity
          
          puts "#{i}, #{j}, #{tags[i].name}, #{tags[j].name}: #{distances[i, j]}"
          Settings.links_weights_semantic = 0.5 * ((i * tags.size).to_f / total_computations.to_f)
        end
      end
      
      for i in 0...tags.size
        for j in i...tags.size
          if distances[i, j] < Infinity
            cost = -Math.log(1 - (distances[i, j] / max_distance))
            Link.update_or_create(tags[i], tags[j], cost, nil)
            Link.update_or_create(tags[j], tags[i], cost, nil)
          end
          
          Settings.links_weights_semantic = 0.5 + 0.5 * ((i * tags.size).to_f / total_computations.to_f)
        end
      end
      
      Settings.links_weights_semantic = 1
    end
  
    #-----------------------------------------------------#
    # links:weights:social: Compute tag-to-sound weights. #
    #-----------------------------------------------------#
    desc "Calculates link costs between sounds and tags in the network."
    
    task :social => :environment do
      puts "Loading sounds."
      sounds = Sound.find(:all)
      puts "Loading tags."
      tags = Tag.find(:all)
      
      votes = Matrix.rows(Array.new(sounds.size) {Array.new(tags.size, Infinity)})
      
      # Compute log-probability for each link.
      sum_votes = 0
      
      puts "Loading votes."
      sounds.each_with_index do |sound, i|
        puts "\tSound #{i} / #{sounds.size}"
        sound_tags = sound.tag_counts_on(:tags)
        total = sound.taggings.collect{|tagging| tagging.tagger}.uniq.size
        
        sound_tags.each_with_index do |tag, j|
          vote = tag.count.to_f / total.to_f
          votes[i, tags.index(sound_tags[j])] = vote
          sum_votes += vote
        end
        
        Settings.links_weights_social = 0.5 * (i.to_f / sounds.size.to_f) 
      end
      
      puts "Updating links."
      for i in 0...sounds.size
        puts "\tSound #{i} / #{sounds.size}"
        for j in 0...tags.size
          if votes[i, j] < Infinity
            value = -Math.log(votes[i, j] / sum_votes)
          
            Link.update_or_create(sounds[i], tags[j], value, nil)
            Link.update_or_create(tags[j], sounds[i], value, nil)
          end
          
          Settings.links_weights_social = 0.5 + 0.5 * (i * tags.size + j).to_f / (sounds.size * tags.size).to_f
        end
      end
      
      Settings.links_weights_social = 1
    end
  end
end