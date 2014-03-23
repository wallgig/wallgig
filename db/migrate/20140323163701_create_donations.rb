class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.references :user, index: true
      t.string :email
      t.string :currency, null: false, limit: 3
      t.integer :cents, null: false
      t.integer :base_cents, null: false
      t.boolean :anonymous, null: false, default: true
      t.datetime :donated_at
    end
  end
end
