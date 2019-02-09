class FlightsController < ApplicationController
    require 'http'
    require 'faker'
    
    def index
        flights = JSON.parse(HTTP.get('https://gist.githubusercontent.com/bgdavidx/132a9e3b9c70897bc07cfa5ca25747be/raw/8dbbe1db38087fad4a8c8ade48e741d6fad8c872/gistfile1.txt'), symbolize_names: true)

        preffered_duration = params[:preffered_duration]
        preffered_timerange = params[:preffered_timerange]
        preffered_carriers = params[:preffered_carriers]

        if preffered_duration.present?
            flights = flights.select{ |f| ((DateTime.parse(f[:arrivalTime])-DateTime.parse(f[:departureTime])) * 24 * 60).to_i < preffered_duration.to_i}
        end

        if preffered_timerange.present? 
            puts preffered_timerange.split('-')
            preffered_start = DateTime.parse(preffered_timerange.split('-').first)
            preffered_end = DateTime.parse(preffered_timerange.split('-').second)
            flights = flights.select { |f| preffered_start < DateTime.parse(f[:departureTime]) && preffered_end> DateTime.parse(f[:arrivalTime]) }
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
            flights = Flight.where(origin_id: origin_airport.id)
            @list_of_cheapest_flights = []
            Airport.all.each do |a|
                cheapest_flight = flights.where(destination_id: a.id).order(:price).first
                if cheapest_flight.present?
                    @list_of_cheapest_flights.push({ airport_name: a.name, airport_address: a.address, airline_name: cheapest_flight.airline.name, airline_abbreviation: cheapest_flight.airline.abbreviation})
                end
            end

            render :json => @list_of_cheapest_flights
        else
            render :json => {'error': 'no_such_origin'}
        end
    end

    def fastest_airline
        airlines = []
        Airline.all.each do |t|
            number_of_flights = 0
            flight_speed = 0
            Flight.where(airline_id: t.id).each do |f|
                flight_speed += f.distance/f.duration
                number_of_flights += 1
            end
            if number_of_flights > 0
                average = flight_speed/number_of_flights
                airlines.push({airline_id: t.id, average_flight_speed: average})
            end
        end
        airline = airlines.max_by{|a| a[:average_flight_speed]}

        if airline.present?
            @airline = Airline.find_by(id: airline[:airline_id])
            render :json => @airline
        else
            render :json => { 'error': 'no_airlines_in_db'}
        end
    end

    def reseed_with_faker
        Airport.delete_all
        Airline.delete_all
        Flight.delete_all

        50.times do 
            name = Faker::Company.unique.name
            abbreviation = name[0,3].upcase
            Airline.create(name: name, abbreviation: abbreviation)
        end

        300.times do
            name = Faker::Address.unique.city
            code = name[0,3].upcase
            address = Faker::Address.unique.street_address
            Airport.create(name: name, code: code, address: address)
        end

        500.times do
            number = Faker::Code.unique.nric
            offset = rand(Airport.count)
            offset2 = rand(Airport.count)
            origin_airport = Airport.offset(offset).first
            destination_airport = Airport.offset(offset2).first
            offset3 = rand(Airline.count)
            airline = Airline.offset(offset3).first.id
            prng = Random.new
            price = prng.rand(100..600)
            duration = prng.rand(45..600)
            distance = prng.rand(200..5000)
            puts number, origin_airport, destination_airport, airline, price, duration, distance
            Flight.create(
                number: number,
                origin: origin_airport,
                destination: destination_airport,
                airline_id: airline,
                price: price,
                duration: duration,
                distance: distance
            )
        end

        render :json => { 'result': 'Finished reseeding'}
    end

end
