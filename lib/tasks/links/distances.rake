require 'pqueue'
require 'matrix_extension'

namespace :links do
  desc "Computes shortest path distances between nodes in the network."
  task :distances => :environment do
    progress = ENV['PROGRESS']
    
    #-------------------------#
    # 1. Initialize matrices. #
    #-------------------------#
    puts "Fetching nodes."
    
    nodes = MdsNode.find(:all)
    
    node_ids = nodes.collect {|node| node.id}
    distances = Matrix.infinity(nodes.size, nodes.size)
    
    source_node_ids = ENV['ONLYNEW'] ? node_ids : node_ids.reject{|id| Link.count("first_id = #{id} and not ISNULL(distance)") > 1}
    puts "Only updating new nodes." if ENV['ONLYNEW']
    #---------------------------------------------------------#
    # 2. Compute Dijkstra's algorithm between all node pairs. #
    #---------------------------------------------------------#
    puts "Computing shortest-path distances."
        
    for i in 0...source_node_ids.size
      visited = Array.new(nodes.size, false)
      previous = Array.new(nodes.size, nil)
      shortest = Array.new(nodes.size, Infinity) #distances.row(i).to_a
      queue = PQueue.new(proc {|x, y| shortest[x] < shortest[y]})
      
      queue.push(i)
      visited[i] = true
      shortest[i] = 0
      
      pops = 0
      
      while queue.size != 0
        v = queue.pop
        pops += 1

        visited[v] = true
        
        links = nodes[v].outbound_links
        if links != nil and links.size > 0
          links = links.reject{|link| link.cost == nil || link.cost == Infinity || link.cost < 0}
          
          links.each do |link|
            w = node_ids.index(link.second_id)

            if !visited[w] and shortest[w] > shortest[v] + link.cost
              shortest[w] = shortest[v] + link.cost
              previous[w] = v
              queue.push w
            end
          end
        end
      end
      
      shortest.each_with_index do |distance, j|
        distances[nodes.index(source_node_ids[i]), j] = distance
        distances[j, nodes.index(source_node_ids[i])] = distance
      end
      
      Settings.links_distances = 0.5 * (i + 1) / nodes.size.to_f if progress
      puts "\t#{i}: #{pops}"
    end
    
    #--------------------------------------#
    # 3. Update the links in the database. #
    #--------------------------------------#
    puts "Updating links in the database."
    
    update_index = 0
    total_updates = (nodes.size * nodes.size) / 2
    
    for i in 0...source_node_ids.size
      puts "#{i + 1} / #{nodes.size}"
      
      for j in i...nodes.size
        node_index = nodes.index(source_node_ids[i])
        
        Link.update_or_create(nodes[node_index], nodes[j], nil, distances[node_index, j]) if distances[node_index, j] < Infinity
        Link.update_or_create(nodes[j], nodes[node_index], nil, distances[j, node_index]) if distances[j, node_index] < Infinity
        
        update_index += 1
      end
      
      Settings.links_distance = 0.5 + 0.5 * (update_index / total_updates.to_f) if progress
    end
    
    Settings.links_distances = 1 if progress
  end
end
