namespace :links do
  namespace :weights do
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
  end
end