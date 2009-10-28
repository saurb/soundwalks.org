namespace :mds do
  namespace :load do
    desc "Loads random MDS positions for all sounds and tags."
    task :random => :environment do
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
    
    desc "Loads MDS positions from a specially-formatted CSV file."
    task :file => :environment do
      file = File.open(File.join(RAILS_ROOT, ENV['MDS_FILE']))
      
      file.each_line do |line|
        puts line
        components = line.split(',')
        
        if components.size == 4
          if components[0] == 'sound'
            sound = Sound.find(:first, :conditions => {:filename => components[1]})
            
            if sound
              node = sound.mds_node ? sound.mds_node : sound.build_mds_node
              node.x = components[2]
              node.y = components[3]
              node.w = 0
              node.z = 0
              
              puts "\tSound #{sound.id}: (#{node.x}, #{node.y})"
              
              node.save
            end
          elsif components[0] == 'tag'
            tag = Tag.find(:first, :conditions => {:name => components[1]})
            
            if tag
              node = tag.mds_node ? tag.mds_node : tag.build_mds_node
              node.x = components[2]
              node.y = components[3]
              node.w = 0
              node.z = 0
              
              puts "\tTag #{tag.id}: (#{node.x}, #{node.y})"
              
              node.save
            end
          end
        end
      end
      
      Settings.mds_load = 1
    end
  end
end