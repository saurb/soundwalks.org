namespace :links do
  desc "Create empty links between all pairs of nodes for which links do not already exist."
  task :bootstrap => :environment do
    nodes = MdsNode.find(:all)
    
    puts "Creating empty nodes."
    nodes.each_with_index do |node1, i|
      puts "#{i + 1} / #{nodes.size}"
      
      connections = node.outbound_links.collect{|link| link.second_id}
      
      nodes.each do |node2|
        Link.update_or_create(node1, node2, nil, nil) if !connections.index(node2.id)
      end
    end
  end
end
