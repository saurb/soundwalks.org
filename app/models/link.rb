class Link < ActiveRecord::Base
  belongs_to :first, :polymorphic => true
  belongs_to :second, :polymorphic => true
  
  named_scope :find_with_nodes, lambda { |first, second|
    {:conditions => {:first_id => first.id, :second_id => second.id, :first_type => first.class.to_s, :second_type => second.class.to_s}}
  }
  
  def self.only_update(first, second, cost, distance)
    update_strings = []
    update_strings.push("cost = #{cost}") if cost != nil
    update_strings.push("distance = #{distance}") if distance != nil
    
    if update_strings.size > 0
      Link.update_all update_strings.join(","), "first_id=#{first.id} AND second_id = #{second.id} AND first_type='#{first.class.to_s}' AND second_type = '#{second.class.to_s}'"
    end
  end
   
  def self.update_or_create(first, second, cost, distance)
    link = nil

    links = Link.find_with_nodes(first, second)

    if links != nil && links.size > 0
      link = links.first
    else
      link = Link.new
      link.first = first
      link.second = second
    end

    link.cost = cost if cost != nil
    link.distance = distance if distance != nil

    link.save
  end
  
  def self.query_distribution(query, ids, conditional = false)
    response = []
    id_strings = []
    
    ids.each do |id_type, id_list|
      clause = ""
      id_list_string = id_list.join(",")
      
      if id_list_string.size > 0
        id_strings.push "(second_id in (#{id_list_string}) and second_type = '#{id_type}')"
      end
    end
    
    full_id_string = id_strings.join(" or ")
    
    links = full_id_string.length > 0 ? Link.find(:all, :conditions => "first_id = #{query.id} and first_type = '#{query.class.to_s}' and (#{full_id_string})") : nil
    
    if links != nil
      sum = 0
      
      links.each do |link| 
        link.distance = conditional ? exp(-link.distance) : (link.cost > -1 ? exp(-link.cost) : 100000000)
        sum += link.distance
      end
      
      links.each do |link|
        if link.second_type == 'Tag'
          tag = Tag.find(link.second_id)
          
          response.push({:type => link.second_type, :id => link.second_id, :value => link.distance / sum, :name => tag.name})
        else
          response.push({:type => link.second_type, :id => link.second_id, :value => link.distance / sum})
        end
      end
    end
    
    return response
  end
end
