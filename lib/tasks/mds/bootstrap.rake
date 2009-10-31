namespace :mds do
  desc "Creates MDS nodes for sounds and tags that do not have them."
  task :bootstrap => :environment do
    tags = Tag.find(:all)
    sounds = Sound.find(:all)
    
    [tags, sounds].each do |collection|
      collection.each do |source|
        if source.mds_node == nil
          source.create_mds_node
        end
      end
    end
  end
end
