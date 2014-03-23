class CreateDonationGoals < ActiveRecord::Migration
  def change
    create_table :donation_goals do |t|
      t.string :name
      t.date :starts_on, null: false
      t.date :ends_on
      t.integer :cents, null: false
    end
  end
end
