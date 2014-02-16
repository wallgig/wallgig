class CreateReportReasons < ActiveRecord::Migration
  def change
    create_table :report_reasons do |t|
      t.string :reportable_type
      t.string :reason
    end
    add_index :report_reasons, :reportable_type
  end
end
