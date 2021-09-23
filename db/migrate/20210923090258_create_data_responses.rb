class CreateDataResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :data_responses do |t|
      t.string :ip_address
      t.string :city
      t.string :country
    end
  end
end
