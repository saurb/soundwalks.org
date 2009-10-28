namespace :mds do
  desc "Gives CSV output for the votes matrix between sounds and tags."
  task :votes => :environment do
    tags = Tag.find(:all)
    sounds = Sound.find(:all)
    
    tags.each do |tag|
      puts tag.name
    end
    
    sounds.each do |sound|
      tag_count = Tagging.count(:id, :conditions => {:taggable_id => sound.id})
      
      tags.each_with_index do |tag, i|
        value = Tagging.count(:id, :conditions => {:taggable_id => sound.id, :tag_id => tag.id})
        
        print "#{value / tag_count.to_f}"
        if i < tags.size - 1
          print ","
        else
          print "\n"
        end
      end
    end
  end
end

