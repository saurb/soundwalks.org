require 'pqueue'
require 'matrix_extension'

Infinity = 1.0 / 0.0

# Find weights in from links in database and fill weights/edges matrices.
# offset1/offset2 are where each set begins in the list of all nodes.
def fetch_weights(set1, set2, weights, edges, offset1, offset2)
  for i in 0...set1.size
    puts "\t#{i}"
    for j in i...set2.size
      puts "\t\t#{j}"
      links = Link.find_with_nodes(set1[i], set2[j])
      
      if links != nil && links.size > 0
        edges[offset1 + i].push offset2 + j
        edges[offset2 + j].push offset1 + i
        
        value = links.first.cost
        value = Infinity if value < 0
        
        weights[offset1 + i, offset2 + j] = value;
        weights[offset2 + j, offset1 + i] = value;
      end
    end
  end
end

namespace :links do
  #---------------------------------------------------------------------#
  # links:distances: Compute shortest path distances between all nodes. #
  #---------------------------------------------------------------------#  
  desc "Computes shortest path distances between nodes in the network."
  
  task :distances => :environment do
    # 1. Initialize matrices and lists.
    sounds = Sound.find(:all)
    tags = Tag.find(:all)
    nodes = sounds + tags
    
    edges = Array.new(nodes.size) {[]}
    weights = Matrix.rows(Array.new(nodes.size){Array.new(nodes.size, Infinity)})
    
    # 2. Fetch links from database and fill weights/edges matrices.
    puts "Fetching acoustic weights."
    fetch_weights(sounds, sounds, weights, edges, 0, 0)
    
    puts "Fetching semantic weights."
    fetch_weights(tags, tags, weights, edges, sounds.size, sounds.size)
    
    puts "Fetching social weights."
    fetch_weights(sounds, tags, weights, edges, 0, sounds.size)
    
    # 3. Use Dijkstra's algorithm to compute shortest-path distances between nodes.
    puts "Finding shortest paths."
    nodes.each_with_index do |source_node, source_index|
      puts "\t#{source_index}"
      
      # 3.1. Create all the necessary arrays.
      visited = Array.new(nodes.size, false)
      shortest_distances = Array.new(nodes.size, Infinity)
      previous = Array.new(nodes.size, nil)
      queue = PQueue.new(proc {|x,y| shortest_distances[x] < shortest_distances[y]})
      
      # 3.2. Initialize.
      queue.push(source_index)
      visited[source_index] = true
      shortest_distances[source_index] = 0
      
      # 3.3. Compute shortest path between source node and all other reachable nodes.
      while queue.size != 0
        v = queue.pop
        visited[v] = true
        if edges[v]
          edges[v].each do |w|
            if !visited[w] and shortest_distances[w] > shortest_distances[v] + weights[v, w] and weights[v, w]
              shortest_distances[w] = shortest_distances[v] + weights[v, w]
              previous[w] = v
              queue.push w
            end
          end
        end
      end
      
      # 3.4. Update link distances in database.
      shortest_distances.each_with_index do |distance, i|
        Settings.links_distances = (nodes.size * source_index + i).to_f / (nodes.size * nodes.size).to_f
        
        #Link.only_update(nodes[source_index], nodes[i], nil, distance) if distance < Infinity
        Link.update_or_create(nodes[source_index], nodes[i], nil, distance) if distance < Infinity
      end
    end
    
    Settings.links_distances = 1
  end
end
