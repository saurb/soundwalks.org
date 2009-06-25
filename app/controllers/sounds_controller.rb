class SoundsController < ApplicationController
  def index
    @sounds = Sound.find(:all)
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
  
  def show
    @sounds = Sound.find(:all)
    @sound = Sound.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
  
  def new
    @sound = Sound.new
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @sound}
    end
  end
  
  def create
    @sound = Sound.new(params[:sound])
    @sound.file = params[:upload]['file']
    
    respond_to do |format|    
      if @sound.save
        format.html {redirect_to(@sound)}
        format.xml {render :xml => @sound, :status => :created, :location => @sound}
      else
        format.html {render :action => 'new'}
        format.xml {render :xml => @sound.errors, :status => :unprocessible_entity}
      end
    end
  end
  
  # PUT /posts/1
  # PUT /posts/1.xml
  #def update
  #  @post = Post.find(params[:id])#
  #
  #  respond_to do |format|
  #    if @post.update_attributes(params[:post])
  #      flash[:notice] = 'Post was successfully updated.'
  #      format.html { redirect_to(@post) }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end
  
  def destroy
    @sound = Sound.find(params[:id])
    @sound.destroy
    
    respond_to do |format|
      format.html { redirect_to(sounds_url) }
      format.xml { head :ok }
    end
  end
  
  def trajectory
    @sound = Sound.find(params[:id])
    @feature_set = @sound.trajectory params[:type]
    
    respond_to do |format|
      format.xml
    end
  end
end
