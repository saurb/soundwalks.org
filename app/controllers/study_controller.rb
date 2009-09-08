class StudyController < ApplicationController
  def index
  end
  
  def create
    if Study.deliver_contact(params[:contact])
      flash[:notice] = "Thank you for participating in our study!"
      redirect_to(contact_path)
    else
      flash.now[:error] = "An error occurred while submitting your form. Please try again or conact study@soundwalks.org."
      render :index
    end
  end
end
