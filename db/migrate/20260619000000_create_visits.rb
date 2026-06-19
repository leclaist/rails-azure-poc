class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.string :ip_address, limit: 45
      t.timestamps null: false
    end
  end
end
