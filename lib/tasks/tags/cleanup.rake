namespace :tags do
  desc "Clean up tags that are not actually being used."
  task :cleanup => :environment do
    tags = Tag.find(:all)
    
    tags.each do |tag|
      taggings = Tagging.count(:conditions => {:tag_id => tag.id})
      
      if taggings == 0
        puts "Deleting tag #{tag.id}: #{tag.name}"
        tag.destroy
      end
    end
  end
end
