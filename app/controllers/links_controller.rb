require 'matrix'
require 'pqueue'

Infinity = 1.0 / 0.0

# Why Matrix isn't built with this is beyond me.
class Matrix
  def []=(i,j,x)
    @rows[i][j] = x
  end
end

# Normalize a log-likelihood similarity matrix to be a scaled distance matrix.
def normalize_affinity(matrix)
  ones = Matrix.row_vector(Array.new(matrix.row_size) {1})
  diag = Matrix.column_vector(Array.new(matrix.row_size) {|i| matrix[i, i]})
  
  (diag * ones) + (ones.transpose * diag.transpose) - matrix - matrix.transpose
end

class LinksController < ApplicationController
  layout 'site'
  
  before_filter :login_required
  
  def index
    if current_user.admin?
      @links = Link.find(:all)
      
      respond_to do |format|
        format.html
        format.xml {render :xml => @links}
        format.js {render :json => @links}
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  def set
    if current_user.admin?
      # Find the link, if it exists.
      @link = Link.find(:conditions => {:first_id => params[:first_id], :second_id => params[:second_id], :first_type => params[:first_type], :second_type => params[:second_type]})
      
      # If the link doesn't exist, create it.
      if !@link
        @link = Link.new
        @link.first_id = params[:first_id]
        @link.second_id = params[:second_id]
        @link.first_type = params[:first_type]
        @link.second_type = params[:second_type]
      end
      
      # Update the cost and save.
      @link.cost = params[:cost]
      
      @link.save
      
      # Respond to the client.
      respond_to do |format|
        format.xml {render :xml => @link}
        format.js {render :js => @link}
      end
    else
      redirect_back_or_default '/'
    end
  end
  
  # GET /links/recalculate_sounds
  # Update all the links between sounds by comparing them to each other.
  def recalculate_sounds
    sounds = Sound.find(:all)
    sound_ids = sounds.collect{|sound| sound.id}
    log_probability = Matrix.rows(Array.new(sounds.size) {Array.new(sounds.size) {Infinity}})
    
    # Compute log-probabilities for link costs.
    for i in 0...sounds.size
      for j in i...sounds.size        
        value = sounds[i].compare(sounds[j])
        
        if !value.nan?
          log_probability[i, j] = value
          log_probability[j, i] = value
          update_or_create_link(sounds[i], sounds[j], value, nil)
        else
          value = Math.log(0)
          log_probability[i, j] = value
          log_probability[j, i] = value
        end
      end
    end
    
    # Compute log-scale normalized distance matrix.
    affinity = normalize_affinity(log_probability)
    
    # Update link costs.
    for i in 0...affinity.row_size
      for j in i...affinity.column_size
        if !affinity[i, j].nan? && (affinity[i, j] != Infinity) && (affinity[i, j] != -Infinity)
          update_or_create_link(sounds[i], sounds[j], affinity[i, j], nil)
          update_or_create_link(sounds[j], sounds[i], affinity[i, j], nil)
        end
      end
    end
    
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = "Acoustic links successfully recalculated."
        render :action => 'index'
      }
    end
  end
  
  # GET /links/recalculate_tags
  # Update all links between tags--for now, just set them to Infinity.
  # TODO: Use WordNet.
  def recalculate_tags
    @tags = Tag.find(:all)
    
    @tags.each do |first|
      @tags.each do |second|
        update_or_create_link(first, second, Infinity, nil)
        update_or_create_link(second, first, Infinity, nil)
      end
    end
    
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = "Tag links successfully recalculated."
        render :action => 'index'
      }
    end
  end
  
  # GET /links/recalculate_votes
  # Update all links between sounds and tags according to the community tagging.
  def recalculate_votes
    @sounds = Sound.find(:all)
    
    # Compute log-probability for each link.
    @sounds.each do |sound|
      tags = sound.tag_counts_on(:tags)
      total = sound.taggings.collect{|tagging| tagging.tagger}.uniq.size
      
      tags.each do |tag|
        value = -Math.log(tag.count.to_f / total.to_f)
        
        update_or_create_link(sound, tag, value, nil)
        update_or_create_link(tag, sound, value, nil)
      end
    end
    
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = "Vote links successfully recalculated."
        render :action => 'index'
      }
    end
  end
  
  # GET /links/recalculate_distances
  # Use Dijkstra's algorithm to compute shortest path distances between all nodes, including sounds and tags.
  def recalculate_distances
    sounds = Sound.find(:all)
    tags = Tag.find(:all)
    nodes = sounds + tags
    
    # Compute edge and weight matrices.
    edges = Array.new(nodes.size) {[]}
    weights = Matrix.rows(Array.new(nodes.size){Array.new(nodes.size, Infinity)})
    
    # Fill sound-sound weights.
    for i in 0...sounds.size
      for j in i...sounds.size
        links = Link.find_with_nodes(sounds[i], sounds[j])
        if links != nil && links.size > 0
          edges[i].push j
          weights[i, j] = links.first.cost
          weights[j, i] = links.first.cost
        end
      end
    end
    
    # Fill sound-tag weights.
    for i in 0...sounds.size
      for j in 0...tags.size
        links = Link.find_with_nodes(sounds[i], tags[j])
        
        if links != nil && links.size > 0
          edges[i].push j + sounds.size
          weights[i, j + sounds.size] = links.first.cost
          weights[i + sounds.size, j] = links.first.cost
        end
      end
    end
    
    puts weights
        
    # Dijkstra.
    nodes.each_with_index do |source_node, source_index|
      # Create all the necessary arrays.
      visited = Array.new(nodes.size, false)
      shortest_distances = Array.new(nodes.size, Infinity)
      previous = Array.new(nodes.size, nil)
      queue = PQueue.new(proc {|x,y| shortest_distances[x] < shortest_distances[y]})
      
      # Initialize.
      queue.push(source_index)
      visited[source_index] = true
      shortest_distances[source_index] = 0
      
      while queue.size != 0
        v = queue.pop
        visited[v] = true
        if edges[v]
          edges[v].each do |w|
            if !visited[w] and shortest_distances[w] > shortest_distances[v] + weights[v, w]
              shortest_distances[w] = shortest_distances[v] + weights[v, w]
              previous[w] = v
              queue.push w
            end
          end
        end
      end
      
      shortest_distances.each_with_index do |distance, i|
        update_or_create_link(nodes[source_index], nodes[i], nil, distance) if distance < Infinity
      end
    end
    
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = "All distances successfully computed."
        render :action => 'index'
      }
    end
  end
  
  def delete_all
    @links = Link.find(:all)
    @links.each do |link|
      link.destroy
    end
    
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html {
        flash.now[:notice] = "All links successfully destroyed."
        render :action => 'index'
      }
    end
  end
  
  protected
    def update_or_create_link(first, second, cost, distance)
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
end
