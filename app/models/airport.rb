class Airport < ActiveRecord::Base
	has_many :incoming_flights, :class_name => 'Flight',  :foreign_key => 'destination_id'
    has_many :outgoing_flights, :class_name => 'Flight',  :foreign_key => 'origin_id' 
end