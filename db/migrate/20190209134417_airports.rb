class Airports < ActiveRecord::Migration[5.2]
  def change
    create_table :airports do |t|
      t.string :name
      t.string :code
      t.text :address
 
      t.timestamps
    end
  end
end
