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
      node.outbound_links.each do |link|
        j = node_ids.index(link.second.id)
        
        distances[i, j] = link.distance
        costs[i, j] = link.cost
      end
    end
    
    puts "Constructing node names list."
    node_names = nodes.collect{|node| node.owner_type == 'Tag' ? "tag,#{node.owner.name}" : "sound,#{node.owner.filename}"}
    
    puts "Distances:"
    puts distances.row_vectors.collect{|vector| vector.to_a.join(',')}.join("\n")
    
    puts "Costs:"
    puts costs.row_vectors.collect{|vector| vector.to_a.join(',')}.join("\n")
    
    puts "Names:"
    puts node_names.collect{|name| "\t#{name}"}.join("\n")
  end
end
