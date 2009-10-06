namespace :links do
  task :sound_to_sound do
    sounds = Sound.find(:all)
    sound_ids = sounds.collect{|sound| sound.id}
    log_probability = Matrix.rows(Array.new(sounds.size) {Array.new(sounds.size) {Infinity}})
    
    puts "Computing similarities."
    # Compute log-probabilities for link costs.
    for i in 0...sounds.size
      for j in i...sounds.size        
        value = sounds[i].compare(sounds[j])
        
        if !value.nan?
          log_probability[i, j] = value
          log_probability[j, i] = value
        else
          value = Math.log(0)
          log_probability[i, j] = value
          log_probability[j, i] = value
        end
        
        puts "\t(#{i}, #{j}) = #{value}"
      end
    end
    
    puts "Creating normalizd affinity matrix."
    # Compute log-scale normalized distance matrix.
    affinity = normalize_affinity(log_probability)
    
    puts "Updating links."
    # Update link costs.
    for i in 0...affinity.row_size
      for j in i...affinity.column_size
        puts "\t(#{i}, #{j})"
        
        if !affinity[i, j].nan? && (affinity[i, j] != Infinity) && (affinity[i, j] != -Infinity)
          update_or_create_link(sounds[i], sounds[j], affinity[i, j], nil)
          update_or_create_link(sounds[j], sounds[i], affinity[i, j], nil)
        end
      end
    end
  end
end