class StudyController < ApplicationController
  def index
    @sounds = Sound.find(:all, :order => 'study_coverage', :limit => 20)
  end
  
  def create
    if Study.deliver_study(params[:study])
      flash[:notice] = "Thank you for participating in our study!"
      redirect_to(study_path)
    else
      flash.now[:error] = "An error occurred while submitting your form. Please try again or conact study@soundwalks.org."
      render :index
    end
  end
end
