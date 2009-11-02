class StudyController < ApplicationController
  #-------------------------------------------------------------------------------------#
  # GET /study                                                                          #
  #   Shows the study, with the 10 sounds that have been tagged the least in the study. #
  #-------------------------------------------------------------------------------------#
  
  def index
    @sounds = Sound.find(:all, :order => 'study_coverage ASC', :limit => 10)
  end
  
  #---------------------------------------------------------------------------------------------------#
  # POST /study                                                                                       #
  #   Emails the results of the study to the administrator and lets the participant continue tagging. #
  #---------------------------------------------------------------------------------------------------#
  
  def create
    if Study.deliver_study(params[:ids], params[:tags])
      flash[:notice] = "Your responses were successfully recorded. If you would like to help us out more, just continue tagging sounds. Each time you complete a set of sounds, you will be given a new set."
      redirect_to(study_path)
    else
      flash.now[:error] = "An error occurred while submitting your form. Please try again or contact study@soundwalks.org."
      render :index
    end
  end
end
