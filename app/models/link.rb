Infinity = 1.0 / 0.0

#-----------------------------------------------------------------#
# A connection in the network between two nodes (tags or sounds). #
#   Each link has a cost associated with it (link weight), and a  #
#   distance, which is the shortest path distance between the two #
#   nodes given the rest of the network.                          #
#-----------------------------------------------------------------#

class Link < ActiveRecord::Base
  belongs_to :first, :class_name => 'MdsNode'
  belongs_to :second, :class_name => 'MdsNode'
  
  #--------------------------------------------------------#
  # Finds a link based upon the nodes to which it belongs. #
  #--------------------------------------------------------#
  
  named_scope :find_with_nodes, lambda { |first, second|
    {:conditions => {:first_id => first.id, :second_id => second.id}}
  }
  
  #---------------------------------------------------------------------------------------------#
  # Either updates or creates a link. If either cost or distance are nil, they are not updated. #
  #---------------------------------------------------------------------------------------------#
  
  def self.update_or_create(first, second, cost, distance)
    link = Link.find(:first, :conditions => {:first_id => first.id, :second_id => second.id})

    if link == nil
      link = Link.new
      link.first = first
      link.second = second
    end
    
    link.cost = cost if cost != nil
    link.distance = distance if distance != nil
    
    link.save
    
    return link
  end
  
  def self.update_or_create_by_id(first, second, cost, distance)
    link = Link.find(:first, :conditions => {:first_id => first, :second_id => second})
    
    if link == nil
      link = Link.new
      link.first = MdsNode.find(first)
      link.second = MdsNode.find(second)
    end
    
    link.cost = cost if cost != nil
    link.distance = distance if distance != nil
    
    link.save
    
    return link
  end
  
  #--------------------------------------------------------------------------------------------------------#
  # Same as update_or_create, but does not create a new link if one doesn't already exist.                 #
  #   This is more efficient if you know that the link already exists, as you don't need to find it first. #
  #--------------------------------------------------------------------------------------------------------#
  
  def self.only_update(first, second, cost = nil, distance = nil)
    params = {}
    params[:cost] = cost if cost != nil
    params[:distance] = distance if distance != nil
    
    Link.update_all(params.collect{|param, value| "#{param} = #{value}"}.join(','), "first_id = #{first.id} and second_id = #{second.id}") if params.size
  end
  
  #-------------------------------------------------------------------------------#
  # Obtains a probabilistic distribution over a list of nodes given a query node. #
  #-------------------------------------------------------------------------------#
  
  def self.query_distribution(query, ids = [], conditional = false)
    response = []
    
    links = ids.size > 0 ? Link.find(:all, :conditions => {:first_id => query.id, :second_id => ids}) : nil
    
    if links != nil
      sum = 0
      
      links.each do |link| 
        if link.distance != nil
          link.distance = conditional ? (link.cost ? ((link.cost > -1 ? exp(-link.cost) : 0)) : 0) : exp(-link.distance)
          sum += link.distance if link.distance < Infinity
        end
      end
      
      if sum < Infinity
        links.each do |link|
          response.push({:id => link.second_id, :value => link.distance / sum}) if link.distance != nil and (link.distance / sum) < Infinity
        end
      end
    end
    
    return response
  end
end
