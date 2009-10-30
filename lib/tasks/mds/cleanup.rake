namespace :mds do
  desc "Cleans up MDS nodes for sounds and tags that no longer exist."
  task :cleanup => :environment do
    nodes = MdsNode.find(:all)
    
    nodes.each do |node|
      if node.owner == nil
        node.destroy
        
        puts "Destroying node #{node.id}."
      end
    end
  end
end
