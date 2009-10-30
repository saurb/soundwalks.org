require 'pqueue'
require 'matrix_extension'

namespace :links do
  desc "Computes shortest path distances between nodes in the network."
  task :distances => :environment do
    #-------------------------#
    # 1. Initialize matrices. #
    #-------------------------#
    puts "Fetching weights."
    
    nodes = MdsNode.find(:all)
    node_ids = nodes.collect {|node| node.id}
    
    distances = Matrix.infinity(nodes.size, nodes.size)
    weights = Matrix.infinity(nodes.size, nodes.size)
    edges = Array.new(nodes.size) {[]}
    
    #---------------------------------------------------------#
    # 2. Compute Dijkstra's algorithm between all node pairs. #
    #---------------------------------------------------------#
    puts "Computing shortest-path distances."
    
    for i in 0...nodes.size      
      visited = Array.new(nodes.size, false)
      previous = Array.new(nodes.size, nil)
      shortest = distances.row(i).to_a
      queue = PQueue.new(proc {|x, y| shortest[x] < shortest[y]})
      
      queue.push(i)
      visited[i] = true
      shortest[i] = 0
      
      pops = 0
      
      while queue.size != 0
        v = queue.pop
        pops += 1
        visited[v] = true
        
        if nodes[i].outbound_links.size > 0
          nodes[i].outbound_links.each do |link|
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
        distances[i, j] = distance
        distances[j, i] = distance
        
        Link.update_or_create(nodes[i], nodes[j], nil, distance) if distance < Infinity
        Settings.links_distances = (nodes.size * i + j).to_f / (nodes.size * nodes.size).to_f
      end
      
      puts "\t#{i}: #{pops}"
    end
    
    Settings.links_distances = 1
  end
end
