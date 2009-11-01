namespace :links do
  namespace :weights do
    desc "Calculates link costs between tags in the network."
    task :semantic => :environment do
      include WordnetHelper
      
      #----------------#
      # 1. Fetch tags. #
      #----------------#
      puts "1. Fetching all tags."
      
      tags = Tag.find(:all)
      
      #--------------------------------------------------------#
      # 2. Compute semantic similarity between all tags pairs. #
      #--------------------------------------------------------#
      puts "2. Computing similarities between tags."
      
      distances = Matrix.infinity(tags.size, tags.size)
      max_distance = 0
      
      for i in 0...tags.size
        puts "\t#{i + 1} / #{tags.size}: #{tags[i].name}"
        
        for j in i...tags.size
          distances[i, j] = jcn_distance(tags[i].name, tags[j].name)
          max_distance = distances[i, j] if distances[i, j] > max_distance and distances[i, j] < Infinity
          
          puts "\t\t#{j - i + 1} / #{tags.size - i}: #{tags[j].name}: #{distances[i, j]}"
        end
      end
      
      #------------------------------#
      # 3. Update links in database. #
      #------------------------------#
      puts "3. Updating links in database."
      
      for i in 0...tags.size
        puts "\t#{i + 1} / #{tags.size}"
        
        for j in i...tags.size
          if distances[i, j] < Infinity
            cost = -Math.log(1 - (distances[i, j] / max_distance))
            Link.update_or_create(tags[i].mds_node, tags[j].mds_node, cost, nil)
            Link.update_or_create(tags[j].mds_node, tags[i].mds_node, cost, nil)
          end
        end
      end
    end
  end
end