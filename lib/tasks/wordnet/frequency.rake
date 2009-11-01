namespace :wordnet do
  desc "Loads frequency counts for all tags from a corpus."
  task :frequency => :environment do
    WordnetNode.destroy_all
    
    file = File.open(File.join(RAILS_ROOT, ENV['IC_FILE']))
    
    file.each_line do |line|
      values = line.split(' ')
      
      if values.size > 1
        node = WordnetNode.new
        
        node.synset_key = values.first.to_i
        node.pos = values.first[-1..-1]
        node.frequency = values.second.to_i
        node.root = values.size > 2
        
        node.save
      end
    end
  end
end