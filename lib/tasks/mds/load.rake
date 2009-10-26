namespace :mds do
  task :load => :environment do
    sounds = Sound.find(:all)
    tags = Tag.find(:all)
    
    sounds.each_with_index do |sound, i|
      node = sound.mds_node ? sound.mds_node : sound.build_mds_node
      node.x = rand(100).to_f / 100.0
      node.y = rand(100).to_f / 100.0
      node.z = rand(100).to_f / 100.0
      node.w = rand(100).to_f / 100.0
            
      node.save
      
      Settings.mds_load = 0.5 * i / sounds.size.to_f
    end
    
    tags.each_with_index do |tag, i|
      node = tag.mds_node ? tag.mds_node : tag.build_mds_node
      node.x = rand(100).to_f / 100.0
      node.y = rand(100).to_f / 100.0
      node.z = rand(100).to_f / 100.0
      node.w = rand(100).to_f / 100.0
      
      node.save
      
      Settings.mds_load = 0.5 + 0.5 * i / tags.size.to_f
    end
    
    Settings.mds_load = 1
  end
end
