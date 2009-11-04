require 'pqueue'
require 'matrix_extension'

namespace :links do
  desc "Calculates shortest path distances between nodes in the network."
  task :distances => :environment do
    start_time = Time.now
    
    #-------------------------------------------#
    # 1. Extract link costs as a sparse matrix. #
    #-------------------------------------------#
    puts "Loading all links."
    
    costs = {}
    link_ids = {}
    
    links = Link.find(:all, :order => "first_id asc, second_id asc")
    
    links.each_with_index do |link, i|
      link_ids[link.first_id] = {} if !link_ids[link.first_id]
      link_ids[link.first_id][link.second_id] = link.id
      
      if link.cost
        costs[link.first_id] = {} if !costs[link.first_id]
        costs[link.first_id][link.second_id] = link.cost
      end
    end
    
    #-------------------------------------------------------#
    # 2. Peform Dijkstra's algorithm for every source node. #
    #-------------------------------------------------------#
    puts "Finding shortest paths."
    
    distances = {}
    index = 0
    
    costs.each do |source, dummy|
      visited = {source => true}
      shortest = {source => 0}
      previous = {}
      
      queue =  PQueue.new(proc {|x, y| shortest[x] < shortest[y]})
      queue.push source
      
      while queue.size != 0
        node = queue.pop
        
        visited[node] = true
        shortest[node] = Infinity if !shortest[node]
        
        costs[node].each do |neighbor, cost|
          shortest[neighbor] = Infinity if !shortest[neighbor]
          
          if !visited[neighbor] and shortest[neighbor] > shortest[node] + cost
            shortest[neighbor] = shortest[node] = cost
            previous[neighbor] = node
            
            queue.push neighbor
          end
        end
      end
      
      distances[source] = {}
      shortest.each do |id, distance|
        distances[source][id] = distance
      end
      
      puts "\t#{index + 1} / #{costs.size} (#{source}): #{distances[source].size} distances."
      index += 1
    end
    
    #------------------------------------------------------------------------#
    # 3. Update any existing links in the database.                          #
    #   Presumably, updating in bulk like this avoids multiple transactions. #
    #------------------------------------------------------------------------#
    puts "Updating existing records in the database."
    
    index = 0
    
    Link.transaction do
      distances.each do |source, neighbors|
        puts "\t#{index + 1} / #{distances.size} (#{source})"
        index += 1
        
        neighbors.each do |neighbor, distance|
          Link.update(link_ids[source][neighbor], :distance => distance) if link_ids[source][neighbor]
        end
      end
    end
    
    #------------------------------------------#
    # 4. Insert any new links in the database. #
    #------------------------------------------#
    puts "Inserting new records into database."
    
    index = 0
    
    #file = File.open(File.join(RAILS_ROOT, '/data/temp_inserts.csv'), 'w')
    #distances.each do |source, neighbors|
    #  neighbors.each do |neighbor, distance|
    #    file << "#{source},#{neighbor},NULL,#{distance}"
    #  end
    #end
    #
    #file.close
    #
    #Link.connection.execute("load data infile '#{RAILS_ROOT}/data/temp_inserts.csv' into table links fields terminated by ','")
    
    Link.transaction do
      distances.each do |source, neighbors|
        puts "\t#{index + 1} / #{distances.size} (#{source})"
        index += 1
        
        neighbors.each do |neighbor, distance|    
          Link.create(:cost => nil, :distance => distance, :first_id => source, :second_id => neighbor) if !link_ids[source][neighbor]
        end
      end
    end
    
    puts "Elapsed time: #{Time.now - start_time}"
  end
end
