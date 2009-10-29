namespace :links do
  desc "Cleans up links between nonexistent nodes in the network."
  task :cleanup => :environment do
    links = Link.find(:all)
    
    links.each do |link|
      destroyed = false
      
      [[:first_id, :first_type], [:second_id, :second_type]].each do |pair|
        if !destroyed
          node = nil
          if links[pair[1]] == 'Sound'
            node = Sound.find(pair[0])
          else
            node = Tag.find(pair[0])
          end
        
          if node == nil
            link.destroy
            destroyed = true
          end
        end
      end
    end
  end
end
