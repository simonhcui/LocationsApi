class CreateSubmitResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :submit_responses do |t|
      t.string :status_code
      t.string :description
    end
  end
end
