After instaling ruby and cloning, go into the project forlder and run following commands > bundle install  then > rails db:migrate

To start the project use command rails s.

The project will be started on port 3000.

Then to seed database with 50 airlines, 300 airports, and 1000 flights go to localhost:3000/api/v1/reseed_with_faker

API endpoints Documentation:

localhost:3000/api/v1/flights?preffered_duration={integer for minutes}&preffered_timerange=22.02.2018 12:30:10-28.02.2018 12:30:10&preffered_carriers=FR,SW,AA

localhost:3000/api/v1/fastest_flight_between?origin={origin_airport_id}&destination={destination_airport_id}

localhost:3000/api/v1/cheapest_flights_from?origin={origin_airport_id}

localhost:3000/api/v1/fastest_airline
