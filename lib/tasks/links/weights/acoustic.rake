require 'matrix_extension'

namespace :links do
  namespace :weights do
    desc "Calculates link costs between sounds in the network."
    task :acoustic => :environment do
      #----------------------#
      # 1. Initialize lists. #
      #----------------------#
      puts "1. Loading all sounds."
      
      sounds = Sound.find(:all)
      comparisons = Array.new(sounds.size)
      comparators = Array.new(sounds.size, nil)
      self_comparison = Array.new(sounds.size, nil)
      costs = Matrix.infinity(sounds.size, sounds.size)
      
      #-------------------------------------------#
      # 2. Find which sounds need to be compared. #
      #-------------------------------------------#
      puts "2. Finding which sounds need to be compared."
      
      for i in 0...sounds.size
        comparisons[i] = []
        
        for j in i...sounds.size
          link = Link.find(:first, :conditions => {:first_id => sounds[i].mds_node.id, :second_id => sounds[j].mds_node.id})
          comparisons[i].push j if link == nil || link.cost == nil || link.cost < 0 || link.cost == Infinity
        end
        
        print "\tFind sound #{i + 1} / #{sounds.size}"
        print comparisons[i].size > 0 ? ": #{comparisons[i].collect{|id| id + 1}.join(', ')}\n" : "\n" 
      end
      
      #------------------------------------------------#
      # 3. Compare them and add links to the database. #
      #------------------------------------------------#
      puts "3. Comparing sounds."
      
      comparisons.each_with_index do |sounds_to_compare, i|
        if sounds_to_compare.size > 0
          puts "\tCompare sound #{i + 1} / #{comparisons.size} (sound #{sounds[i].id}, node #{sounds[i].mds_node.id})"
          
          comparators[i] = sounds[i].get_comparator if comparators[i] == nil
          self_comparison[i] = comparators[i].compare(comparators[i]) if self_comparison[i] == nil
          
          sounds_to_compare.each_with_index do |j, index|
            puts "\t\tCompare sound #{j + 1} (sound #{sounds[j].id}, node #{sounds[j].mds_node.id}) (#{index + 1} / #{sounds_to_compare.size})"
            
            comparators[j] = sounds[j].get_comparator if (comparators[j] == nil)
            self_comparison[j] = comparators[j].compare(comparators[j]) if self_comparison[j] == nil
            
            i_to_j = comparators[i].compare(comparators[j])
            j_to_i = comparators[j].compare(comparators[i])
            
            costs[i, j] = self_comparison[i] + self_comparison[j] - i_to_j - j_to_i
          end
        end
      end
      
      #-------------------------------#
      # Update costs in the database. #
      #-------------------------------#
      puts "4. Updating database."
      
      Link.transaction do
        comparisons.each_with_index do |sounds_to_compare, i|
          puts "\tUpdate sound #{i + 1} / #{comparisons.size} (sound #{sounds[i].id}, node #{sounds[i].mds_node.id})"
          
          sounds_to_compare.each do |j|
            cost = costs[i, j]
            
            if !cost.nan? && cost < Infinity && cost >= 0
              Link.update_or_create(sounds[i].mds_node, sounds[j].mds_node, cost, nil)
              Link.update_or_create(sounds[j].mds_node, sounds[i].mds_node, cost, nil)
            else
              puts "\t\tInvalid cost #{i}, #{j} (sound #{sounds[i].id}/node #{sounds[i].mds_node.id}, sound #{sounds[j].id}/node #{nounds[j].mds_nodes.id}): (self[i]: #{self_comparisons[i]}, self[j]: #{self_comparisons[j]})"
            end
          end
        end
      end
    end
  end
end