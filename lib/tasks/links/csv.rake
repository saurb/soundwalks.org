require 'matrix_extension'

namespace :links do
  desc "Prints out a cost and distance matrix for the network and a list of sounds and tags that are associated."
  task :csv => :environment do
    puts "Loading all nodes."
    nodes = MdsNode.find(:all)
    node_ids = nodes.collect{|node| node.id}
    
    distances = Matrix.infinity(nodes.size, nodes.size)
    costs = Matrix.infinity(nodes.size, nodes.size)
    
    puts "Constructing matrices."
    nodes.each_with_index do |node, i|
      puts "\t#{i + 1} / #{nodes.size}"
      node.outbound_links.each do |link|
        j = node_ids.index(link.second.id)
        
        distances[i, j] = link.distance
        costs[i, j] = link.cost
      end
    end
    
    puts "Constructing node names list."
    node_names = nodes.collect{|node| "#{node.owner_type},#{node.owner_id}"}
    
    distances_path = File.join(RAILS_ROOT, '/data/mds/distances.csv')
    costs_path = File.join(RAILS_ROOT, '/data/mds/costs.csv')
    ids_path = File.join(RAILS_ROOT, '/data/mds/ids.csv')
    
    puts "Writing distances to #{distances_path}"
    distances_file = File.open(distances_path, 'w')
    distances_file << distances.csv
    distances_file.close
    
    puts "Writing costs to #{costs_path}"
    costs_file = File.open(costs_path, 'w')
    costs_file << costs.csv
    costs_file.close
    
    puts "Writing ids to #{ids_path}"
    ids_file = File.open(ids_path, 'w')
    ids_file << node_names.collect{|name| "\t#{name}"}.join("\n")
    ids_file.close
  end
end
