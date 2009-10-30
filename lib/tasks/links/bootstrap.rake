namespace :links do
  desc "Create empty links between all pairs of nodes for which links do not already exist."
  task :bootstrap => :environment do
    nodes = MdsNode.find(:all)
    
    puts "Creating empty nodes."
    nodes.each_with_index do |node1, i|
      puts "#{i + 1} / #{nodes.size}"
      
      nodes.each do |node2|
        Link.update_or_create(node1, node2, nil, nil)
      end
    end
  end
end
