#----------------------------------------------------------#
# A friendship from one user to another.                   #
#   UserA -> UserB implies that UserA is followed by UserB #
#   and UserB is following UserA.                          #
#----------------------------------------------------------#

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"
  validates_uniqueness_of :friend_id, :scope => :user_id
end
