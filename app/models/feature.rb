class Feature < ActiveRecord::Base
  belongs_to :sound
  
  validates_presence_of :trajectory, :feature_type
end
