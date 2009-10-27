namespace :mds do
  task :cleanup => :environment do
    nodes = MdsNode.find(:all)
    
    nodes.each do |node|
      sound = Sound.find(:first, :conditions => {:id => node.owner_id})
      tag = Tag.find(:first, :conditions => {:id => node.owner_id})
      
      if sound == nil && tag == nil
        node.destroy
        
        puts "Destroying node #{node.id}."
      else
        puts "Keeping node #{node.id}."
      end
    end
  end
end
