# == Schema Information
#
# Table name: report_reasons
#
#  id              :integer          not null, primary key
#  reportable_type :string(255)
#  reason          :string(255)
#
# Indexes
#
#  index_report_reasons_on_reportable_type  (reportable_type)
#

require 'spec_helper'

describe ReportReason do
  pending "add some examples to (or delete) #{__FILE__}"
end
