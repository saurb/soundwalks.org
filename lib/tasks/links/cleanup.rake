namespace :links do
  desc "Cleans up links between nonexistent nodes in the network."
  task :cleanup => :environment do
    links = Link.find(:all)
    
    links.each do |link|
      if links.first == nil or links.second == nil
        puts "Deleting link #{link.id}: (#{link.first_id}, #{link.second_id})"
        link.destroy
      end
    end
  end
end
