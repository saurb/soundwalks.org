namespace :tags do
  #----------------------------------------------------------------#
  # tags:hypernyms: Add all hypernyms of all tags to the database. #
  #----------------------------------------------------------------#
  desc "Add all hypernyms of all tags to the database."
  
  task :hypernyms => :environment do
    Settings.tags_hypernyms = 0
    
    tags = Tag.find(:all)
    tag_labels = tags.collect{|tag| tag.synset_label}
    ancestor_list = []
    
    tags.each_with_index do |tag, i|
      Settings.tags_hypernyms = (i.to_f / (tags.size - 1).to_f) / 2.0
      
      puts "#{i + 1} / #{tags.size}"
      
      if tag.part_of_speech != "" and tag.synset_label != "" and tag.word_sense
        synset = WordnetRDF::Synset.new(tag.synset_label, tag.part_of_speech, tag.word_sense)
        ancestor_list.push synset.ancestor
        
        if false
          synset.ancestors.each do |ancestor|
            index = tag_labels.index ancestor.label
        
            if !index
              new_tag = Tag.new
              new_tag.synset_label = ancestor.label
              new_tag.name = ancestor.label
              new_tag.synset_id = ancestor.synsetID
              new_tag.word_sense = ancestor.word_sense
              new_tag.part_of_speech = ancestor.part_of_speech
              new_tag.save
          
              puts "\tAdded: #{new_tag.synset_label}-#{new_tag.part_of_speech}-#{new_tag.word_sense}"
          
              tag_labels.push new_tag.synset_label
            end
          end
        end
      end
    end
    
    ancestor_list.each_with_index do |ancestor, i|
      Settings.tags_hypernyms = 0.5 + (i.to_f / (tags.size - 1).to_f) / 2.0
      
      if ancestor
        hypernym_tags = Tag.find(:all, :conditions => {:synset_id => ancestor.synsetID})
      
        if hypernym_tags and hypernym_tags.size > 0
          tags[i].hypernym = hypernym_tags.first.id
          tags[i].save
          puts "Saved hypernym for #{i} (#{tags[i].name})."
        end
      end
    end
    
    Settings.tag_hypernyms = 1
  end
end
