require 'matrix_extension'

namespace :links do
  desc "Prints out a cost and distance matrix for the network and a list of sounds and tags that are associated."
  task :csv2 => :environment do
    links = Link.find(:all)
    nodes = MdsNode.find(:all)
    node_ids = nodes.collect{|node| node.id}
    
    distances = {}
    costs = {}
    
    links.each do |link|
      distances[link.first_id] = {} if !distances[link.first_id]
      distances[link.first_id][link.second_id] = link.distance
      
      costs[link.first_id] = {} if !costs[link.first_id]
      costs[link.first_id][link.second_id] = link.cost
    end
    
    distance_matrix = Matrix.infinity(nodes.size, nodes.size)
    cost_matrix = Matrix.infinity(nodes.size, nodes.size)
    
    nodes.each_with_index do |node1, i|
      nodes.each_with_index do |node2, j|
        distance_matrix[i, j] = distances[node1.id][node2.id] if distances[node1.id] and distances[node1.id][node2.id]
        cost_matrix[i, j] = costs[node1.id][node2.id] if costs[node1.id] and costs[node1.id][node2.id]
      end
    end
    
    distances_path = File.join(RAILS_ROOT, '/data/mds/distances.csv')
    costs_path = File.join(RAILS_ROOT, '/data/mds/costs.csv')
    ids_path = File.join(RAILS_ROOT, '/data/mds/ids.csv')
    
    puts "\ta. Writing distances to #{distances_path}"
    distances_file = File.open(distances_path, 'w')
    distances_file << distance_matrix.csv
    distances_file.close
    
    puts "\tb. Writing costs to #{costs_path}"
    costs_file = File.open(costs_path, 'w')
    costs_file << cost_matrix.csv
    costs_file.close
    
    puts "\tc. Writing ids to #{ids_path}"
    ids_file = File.open(ids_path, 'w')
    ids_file << node_ids.join("\n")
    ids_file.close
  end
  
  task :csv => :environment do
    #----------------#
    # 1. Load nodes. #
    #----------------#
    puts "1. Loading all nodes."
    
    nodes = MdsNode.find(:all)
    node_ids = nodes.collect{|node| node.id}
    
    #------------------------------------------#
    # 2. Construct cost and distance matrices. #
    #------------------------------------------#
    puts "2. Constructing cost and distance matrices."
    
    distances = Matrix.infinity(nodes.size, nodes.size)
    costs = Matrix.infinity(nodes.size, nodes.size)
    
    nodes.each_with_index do |node, i|
      puts "\t#{i + 1} / #{nodes.size}"
      
      node.outbound_links.each do |link|
        j = node_ids.index(link.second.id)
        
        distances[i, j] = link.distance
        costs[i, j] = link.cost
      end
    end
    
    #-----------------#
    # 3. Write files. #
    #-----------------#
    puts "3. Writing files."
    
    distances_path = File.join(RAILS_ROOT, '/data/mds/distances.csv')
    costs_path = File.join(RAILS_ROOT, '/data/mds/costs.csv')
    ids_path = File.join(RAILS_ROOT, '/data/mds/ids.csv')
    
    puts "\ta. Writing distances to #{distances_path}"
    distances_file = File.open(distances_path, 'w')
    distances_file << distances.csv
    distances_file.close
    
    puts "\tb. Writing costs to #{costs_path}"
    costs_file = File.open(costs_path, 'w')
    costs_file << costs.csv
    costs_file.close
    
    puts "\tc. Writing ids to #{ids_path}"
    ids_file = File.open(ids_path, 'w')
    ids_file << node_ids.join("\n")
    ids_file.close
  end
end
