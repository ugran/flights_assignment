class Flights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.string :number
      t.integer :origin_id
      t.integer :destination_id
      t.integer :airline_id
      t.integer :price
      t.integer :duration
      t.integer :distance
 
      t.timestamps
    end
  end
end
