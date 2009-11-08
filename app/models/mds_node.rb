#--------------------------------------------------------------------------------------------#
# A node in the network. Also contains an absolute position in an low-dimensional MDS space. #
#   Position stored in members: .x, .y, .z, and .w.                                          #
#--------------------------------------------------------------------------------------------#

class MdsNode < ActiveRecord::Base
  include ColorHelper
  
  belongs_to :owner, :polymorphic => true
  has_many :outbound_links, :class_name => 'Link', :foreign_key => 'first_id', :dependent => :destroy
  has_many :inbound_links, :class_name => 'Link', :foreign_key => 'second_id', :dependent => :destroy
  
  def color
    hsv_to_rgb(xy_to_hsv([x, y]))
  end
end
