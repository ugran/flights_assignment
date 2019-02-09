Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'api/v1/flights' => "flights#index"
  get 'api/v1/fastest_flight_between' => "flights#fastest_flight_between"
  get 'api/v1/fastest_airline' => 'flights#fastest_airline'
  get 'api/v1/cheapest_flights_from' => 'flights#cheapest_flights_from'
end