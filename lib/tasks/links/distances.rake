require 'pqueue'
require 'matrix_extension'

namespace :links do
  desc "Calculates shortest path distances between nodes in the network."
  task :distances => :environment do
    #-------------------------#
    # 1. Initialize matrices. #
    #-------------------------#
    puts "1. Fetching nodes."
    
    nodes = MdsNode.find(:all)
    node_ids = nodes.collect {|node| node.id}
    source_ids = ENV['ONLYNEW'] ? node_ids.reject{|id| Link.count(:conditions => "first_id = #{id} and ISNULL(distance)") > 0} : node_ids
    source_ids = ENV['ONLYSOUNDS'] ? source_ids.reject{|id| nodes[id].owner_type == 'Tag'} : source_ids
    
    #---------------------------------------------------------#
    # 2. Compute Dijkstra's algorithm between all node pairs. #
    #---------------------------------------------------------#
    puts "2. Computing shortest-path distances."
    puts "\t(Only updating distances for #{source_ids.size} new nodes.)" if ENV['ONLYNEW']
    
    distances = Matrix.infinity(nodes.size, nodes.size)
    
    source_ids.each_with_index do |source, source_index|
      i = node_ids.index(source)
      
      visited = Array.new(nodes.size, false)
      previous = Array.new(nodes.size, nil)
      shortest = Array.new(nodes.size, Infinity) #distances.row(i).to_a
      queue = PQueue.new(proc {|x, y| shortest[x] < shortest[y]})
      
      queue.push i
      visited[i] = true
      shortest[i] = 0.0
      
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
      
      valid_links = 0
      
      shortest.each_with_index do |distance, j|
        distances[i, j] = distance        
        valid_links += 1 if distance != nil and distance < Infinity and distance >= 0
      end
      
      puts "\t#{source_index + 1} / #{source_ids.size} (index: #{i}, node #{nodes[i].id}): #{pops} visited, #{valid_links} valid distances."
    end
    
    #--------------------------------------#
    # 3. Update the links in the database. #
    #--------------------------------------#
    puts "3. Updating links in the database."
    
    Link.transaction do
      source_ids.each_with_index do |source, source_index|
        i = node_ids.index(source)
        
        puts "\tUpdating node #{source_index + 1} / #{source_ids.size} (index: #{i}, node #{nodes[i].id})"

        for j in i...nodes.size
          if distances[i, j] != nil and !distances[i, j].nan? and distances[i, j] < Infinity && distances[i, j] >= 0.0
            Link.update_or_create(nodes[i], nodes[j], nil, distances[i, j])
            Link.update_or_create(nodes[j], nodes[i], nil, distances[i, j])
          else
            puts "\t\tInvalid link (#{i}, #{j}) (node #{nodes[i].id}, node #{nodes[j].id}): #{distances[i, j]}"
          end
        end
      end
    end
  end
end
