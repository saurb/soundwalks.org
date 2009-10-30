namespace :links do
  desc "Create empty links between all pairs of nodes for which links do not already exist."
  task :boostrap => :environment do
    nodes = MdsNode.find(:all)
    
    nodes.each do |node1|
      nodes.each do |node2|
        Link.update_or_create(node1, node2, nil, nil)
      end
    end
  end
end
