namespace :links do
  desc "Cleans up links between nonexistent nodes in the network."
  task :cleanup => :environment do
    links = Link.find(:all)
    
    links.each do |link|
      node1 = MdsNode.find(:first, :conditions => {:id => link.first_id})
      node2 = MdsNode.find(:first, :conditions => {:id => link.second_id})
      
      if node1 == nil or node2 == nil
        puts "Deleting link #{link.id}: (#{link.first_id}, #{link.second_id})"
        link.destroy
      end
    end
  end
end
