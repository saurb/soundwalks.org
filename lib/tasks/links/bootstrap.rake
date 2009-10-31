namespace :links do
  desc "Create empty links between all pairs of nodes for which links do not already exist."
  task :bootstrap => :environment do
    nodes = MdsNode.find(:all)
    
    puts "Creating empty nodes."
    nodes.each_with_index do |node1, i|
      puts "#{i + 1} / #{nodes.size}"
      
      connections = node1.outbound_links.collect{|link| link.second_id}
      
      nodes.each_with_index do |node2, j|
        if !connections.index(node2.id)
          puts "\t#{j}"
          Link.update_or_create(node1, node2, nil, nil) 
      end
    end
  end
end
