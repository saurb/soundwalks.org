class Feature < ActiveRecord::Base
  belongs_to :sound
  
  serialize :trajectory
  
  validates_presence_of :trajectory, :feature_type
end
