# == Schema Information
#
# Table name: reports
#
#  id              :integer          not null, primary key
#  reportable_id   :integer
#  reportable_type :string(255)
#  user_id         :integer
#  description     :text
#  closed_by_id    :integer
#  closed_at       :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  reasons         :text
#
# Indexes
#
#  index_reports_on_closed_by_id                       (closed_by_id)
#  index_reports_on_reportable_id_and_reportable_type  (reportable_id,reportable_type)
#  index_reports_on_user_id                            (user_id)
#

require 'spec_helper'

describe Report do
  describe 'associations' do
    it { should belong_to(:reportable) }
    it { should belong_to(:user) }
    it { should belong_to(:closed_by).class_name('User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:reportable) }
    it { should validate_presence_of(:description) }
  end
end
