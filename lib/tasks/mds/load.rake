namespace :mds do
  namespace :load do
    desc "Loads random MDS positions for all sounds and tags."
    task :random => :environment do
      nodes = MdsNode.find(:all)
      
      nodes.each_with_index do |node, i|
        puts "#{i + 1} / #{nodes.size} (node #{node.id})"
        numbers = Array.new(4) {rand(100) / 100.0}
        node.x = numbers[0]
        node.y = numbers[1]
        node.z = numbers[2]
        node.w = numbers[3]
        
        node.save
      end
    end
    
    desc "Loads MDS positions from a specially-formatted CSV file."
    task :file => :environment do
      file = File.open(File.join(RAILS_ROOT, ENV['MDS_FILE']))
      
      file.each_line do |line|
        puts line
        components = line.split(',')
        
        if components.size >= 3
          node = MdsNode.find(components[0].to_i)
          
          if node
            puts "\tNode #{node.id}: (#{node.x}, #{node.y})"
            
            node.x = components[2] if components.size > 2
            node.y = components[3] if components.size > 3
            node.z = components[4] if components.size > 4
            node.w = components[5] if components.size > 5
            
            node.save
          end
        end
      end
    end
  end
end