#-----------------------------------#
# A feature trajectory for a sound. #
#   Possible types are:             #
#   :loudness                       #
#   :temporal_sparsity              #
#   :spectral_sparsity              #
#   :spectral_centroid              #
#   :transient_index                #
#   :harmonicity                    #
#-----------------------------------#

class Feature < ActiveRecord::Base
  belongs_to :sound
  serialize :trajectory
  validates_presence_of :trajectory, :feature_type
end
