namespace :links do
  desc "Cleans up links between nonexistent nodes in the network."
  task :cleanup => :environment do
    links = Link.find(:all)
    
    links.each do |link|
      destroyed = false
      
      [[:first_id, :first_type], [:second_id, :second_type]].each do |pair|
        if !destroyed
          node = nil
          if link[pair[1]] == 'Sound'
            node = Sound.find(link[pair[0]])
          else
            node = Tag.find(link[pair[0]])
          end
        
          if node == nil
            puts "Deleting link #{link.id}: #{link.first_type}.#{link.first_id} - #{link.second_type}-#{link.second_id}"
            link.destroy
            destroyed = true
          end
        end
      end
    end
  end
end
