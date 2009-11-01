class FriendshipsController < ApplicationController
  before_filter :login_required
  
  # POST /friendships
  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    
    if @friendship.save
      respond_to do |format|
        format.html {
          flash[:notice] = "You are now following #{@friendship.friend.name}."
          redirect_back_or_default @friendship.friend
        }
        format.xml {render :xml => @friendship}
        format.json {render :json => @friendship, :callback => params[:callback]}
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "There was an error following #{@friendship.friend.name}."
          redirect_back_or_default @friendship.friend
        }
        format.xml {render :xml => @friendship.errors, :status => :unprocessible_entity, :location => @friendship}
        format.json {render :json => @friendship.errors, :status => :unprocessible_entity, :callback => params[:callback], :location => @friendship}
      end
    end
  end
  
  # DELETE /friendships/:id
  def destroy
    @friendship = current_user.friendships.find(params[:id])
    @friendship.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = "You are no longer following #{@friendship.friend.name}."
        redirect_back_or_default @friendship.friend
      }
      format.xml {head :ok}
      format.json {head :ok, :callback => params[:callback]}
    end
  end
end
