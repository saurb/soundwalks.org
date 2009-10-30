class Link < ActiveRecord::Base
  belongs_to :first, :class_name => 'MdsNode'
  belongs_to :second, :class_name => 'MdsNode'
  
  named_scope :find_with_nodes, lambda { |first, second|
    {:conditions => {:first_id => first.id, :second_id => second.id}}
  }
   
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
  
  def self.only_update(first, second, cost = nil, distance = nil)
    params = {}
    params[:cost] = cost if cost != nil
    params[:distance] = distance if distance != nil
    
    Link.update_all(params.collect{|param, value| "#{param} = #{value}"}.join(','), "first_id = #{first.id} and second_id = #{second.id}") if params.size
  end
  
  def self.query_distribution(query, ids = [], conditional = false)
    response = []
    
    links = ids.size > 0 ? Link.find(:all, :conditions => {:first_id => query.id, :second_id => ids}) : nil
    
    if links != nil
      sum = 0
      
      links.each do |link| 
        link.distance = conditional ? exp(-link.distance) : (link.cost ? ((link.cost > -1 ? exp(-link.cost) : 0)) : 0)
        sum += link.distance
      end
      
      links.each do |link|
        response.push({:id => link.second_id, :value => link.distance / sum})
      end
    end
    
    return response
  end
end
