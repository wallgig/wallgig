# == Schema Information
#
# Table name: report_reasons
#
#  id              :integer          not null, primary key
#  reportable_type :string(255)
#  reason          :string(255)
#

class ReportReason < ActiveRecord::Base
  validates :reason,          presence: true
  validates :reportable_type, presence: true
  validate do
    if reportable_type.present?
      reportable_class = reportable_type.safe_constantize

      if reportable_class.nil? || !reportable_class.included_modules.include?(Reportable)
        errors.add(:reportable_type, 'is not reportable')
      end
    end
  end

  scope :alphabetically, -> { order(:reason) }
end
