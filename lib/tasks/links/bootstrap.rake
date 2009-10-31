namespace :links do
  desc "Create empty links between all pairs of nodes for which links do not already exist."
  task :bootstrap => :environment do
    nodes = MdsNode.find(:all)
    
    puts "Creating empty nodes."
    nodes.each_with_index do |node1, i|
      connections = node1.outbound_links.collect{|link| link.second_id}
      
      creations = 0
      
      nodes.each_with_index do |node2, j|
        if !connections.index(node2.id)
          creations += 1
          Link.create(:first_id => node1.id, :second_id => node2.id, :cost => nil, :distance => nil)
        end
      end
      
      puts "#{i + 1} / #{nodes.size}: #{creations}"
    end
  end
end
