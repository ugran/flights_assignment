After instaling ruby and cloning > bundle install > rails db:migrate

to start the project > rails s

Then to seed database 50 airlines, 300 airports, and 1000 flights go to localhost:3000/api/v1/reseed_with_faker

API Documentation:

localhost:3000/api/v1/flights?preffered_duration={integer for minutes}&preffered_timerange=22.02.2018 12:30:10-28.02.2018 12:30:10&preffered_carriers=FR,SW,AA

localhost:3000/api/v1/fastest_flight_between?origin={origin_airport_id}&destination={destination_airport_id}

localhost:3000/api/v1/cheapest_flights_from?origin={origin_airport_id}

localhost:3000/api/v1/fastest_airline