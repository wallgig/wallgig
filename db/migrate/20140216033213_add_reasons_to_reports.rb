class AddReasonsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :reasons, :text
  end
end
