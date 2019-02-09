class FlightsController < ApplicationController
    require 'http'
    
    def index
        flights = JSON.parse(HTTP.get('https://gist.githubusercontent.com/bgdavidx/132a9e3b9c70897bc07cfa5ca25747be/raw/8dbbe1db38087fad4a8c8ade48e741d6fad8c872/gistfile1.txt'), symbolize_names: true)

        preffered_duration = params[:preffered_duration]
        preffered_timerange = params[:preffered_timerange]
        preffered_carriers = params[:preffered_carriers]

        if preffered_duration.present?
            flights = flights.select{ |f| ((DateTime.parse(f[:arrivalTime])-DateTime.parse(f[:departureTime])) * 24 * 60).to_i < preffered_duration.to_i}
        end

        if preffered_timerange.present? 
            flights = flights.select { |f| preffered_timerange.first < DateTime.parse(f[:departureTime]) && preffered_timerange.second > DateTime.parse(f[:arrivalTime]) }
        end

        flights = flights.each{ |f| f[:weather] = rand}

        flights.each do |f|
            duration = ((DateTime.parse(f[:arrivalTime])-DateTime.parse(f[:departureTime])) * 24 * 60).to_i
            is_preffered_carrier = 0.9
            if preffered_carriers.present?
                if preffered_carriers.split(',').include? Airline.find(f[:carrier].id).abbreviation
                    is_preffered_carrier = 1
                end
            end
            f[:priority] = duration*is_preffered_carrier*f[:weather]
        end

        @best_flight = flights.sort_by{ |f| f[:priority]}.last

        render :json => @best_flight
    end

    def fastest_flight_between
        if params[:origin].present? && params[:destination].present?
            @flight = Flight.where(origin_id: params[:origin].to_i, destination_id: params[:destination].to_i).order(:duration).first

            render :json => @flight
        end
    end

    def cheapest_flights_from
        origin_airport = Airport.find_by(id: params[:origin].to_i)
        if origin_airport.present?
            flights = origin_airport.outgoing_flights
            list_of_cheapest_flights = []
            Airport.all.each do |a|
                cheapest_flight = flights.where(destination_id: a.id).order(:price).first
                list_of_cheapest_flights.push({ airport_name: a.name, airport_address: a.address, airline_name: cheapest_flight.airline.name, airline_abbreviation: cheapest_flight.airline.abbreviation})
            end

            render :json => @list_of_cheapest_flights
        end
    end

    def fastest_airline
        airlines = []
        Airline.each do |t|
            number_of_flights = 0
            flight_speed = 0
            Flight.where(airline_id: t.id).each do |f|
                flight_speed += f.distance/f.duration
                number_of_flights += 1
            end
            average = flight_speed/number_of_flights
            airlines.push({airline_id: t.id, average_flight_speed: average})
        end
        airline = airlines.max_by{|a| a.average_flight_speed}

        @airline = Airline.find(airline.airline_id)

        render :json => @airline
    end

end
