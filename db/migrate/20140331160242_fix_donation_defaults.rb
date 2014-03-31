class FixDonationDefaults < ActiveRecord::Migration
  def change
    change_column_default :donations, :currency, 'USD'
    change_column_default :donations, :anonymous, false
  end
end
