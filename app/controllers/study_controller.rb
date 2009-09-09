class StudyController < ApplicationController
  layout 'site'
  
  def index
    @sounds = Sound.find(:all, :order => 'study_coverage ASC', :limit => 10)
  end
  
  def create
    if Study.deliver_study(params[:ids], params[:tags])
      flash[:notice] = "Thank you for participating in our study! If you would like to help us out more, just continue tagging sounds. Each time you complete a set of sounds, you will be given a new set."
      redirect_to(study_path)
    else
      flash.now[:error] = "An error occurred while submitting your form. Please try again or contact study@soundwalks.org."
      render :index
    end
  end
end
