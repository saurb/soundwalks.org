namespace :mds do
  task :matlab => :environment do
    tags = Tag.find(:all)
    sounds = Sound.find(:all)
    
    tags.each do |tag|
      puts tag.name
    end
    
    sounds.each do |sound|
      tag_count = Tagging.count(:id, :conditions => {:taggable => sound})
      
      tags.each_with_index do |tag, i|
        value = Tagging.count(:id, :conditions => {:taggable => sound, :tag => tag})
        
        print "#{value / tag_count.to_f}"
        print "\n" if i < tags.size - 1
      end
    end
  end
end

