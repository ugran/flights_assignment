class Flight < ActiveRecord::Base
    belongs_to :origin_airport, class_name: 'Airport'
    belongs_to :destination_airport, class_name: 'Airport'
    belongs_to :airline
end