namespace :links do
  namespace :weights do
    desc "Calculates link costs between tags in the network."
    task :semantic => :environment do
      include WordnetHelper
      
      #-------------------------#
      # 1. Initialize matrices. #
      #-------------------------#
      puts "Fetching all tags."
      
      tags = Tag.find(:all)
      distances = Matrix.infinity(tags.size, tags.size)
      
      total_computations = (tags.size * tags.size) / 2
      max_distance = 0
      
      #--------------------------------------------------------#
      # 2. Compute semantic similarity between all tags pairs. #
      #--------------------------------------------------------#
      puts "Computing similarities between tags."
      
      for i in 0...tags.size
        puts "\t#{i + 1} / #{tags.size}: #{tags[i].name}"
        
        for j in i...tags.size
          distances[i, j] = jcn_distance(tags[i].name, tags[j].name)
          max_distance = distances[i, j] if distances[i, j] > max_distance and distances[i, j] < Infinity
          
          puts "\t\t#{j - i + 1} / #{tags.size - i}: #{tags[j].name}: #{distances[i, j]}"
          Settings.links_weights_semantic = 0.5 * ((i * tags.size).to_f / total_computations.to_f)
        end
      end
      
      #------------------------------#
      # 3. Update links in database. #
      #------------------------------#
      puts "Updating links in database."
      
      for i in 0...tags.size
        puts "\t#{i + 1} / #{tags.size}"
        
        for j in i...tags.size
          if distances[i, j] < Infinity
            cost = -Math.log(1 - (distances[i, j] / max_distance))
            Link.only_update(tags[i].mds_node, tags[j].mds_node, cost, nil)
            Link.only_update(tags[j].mds_node, tags[i].mds_node, cost, nil)
          end
      
          Settings.links_weights_semantic = 0.5 + 0.5 * ((i * tags.size).to_f / total_computations.to_f)
        end
      end
  
      Settings.links_weights_semantic = 1
    end
  end
end