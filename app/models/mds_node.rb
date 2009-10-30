class MdsNode < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  has_many :outbound_links, :class_name => 'Link', :foreign_key => 'first_id', :dependent => :destroy
  has_many :inbound_links, :class_name => 'Link', :foreign_key => 'second_id', :dependent => :destroy
end
