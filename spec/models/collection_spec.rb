# == Schema Information
#
# Table name: collections
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  name                     :string(255)
#  public                   :boolean          default(TRUE)
#  ancestry                 :string(255)
#  position                 :integer
#  created_at               :datetime
#  updated_at               :datetime
#  impressions_count        :integer          default(0)
#  sfw_wallpapers_count     :integer          default(0)
#  sketchy_wallpapers_count :integer          default(0)
#  nsfw_wallpapers_count    :integer          default(0)
#  last_added_at            :datetime
#

require 'spec_helper'

describe Collection do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:favourites).dependent(:nullify) }
    it { should have_many(:wallpapers).through(:favourites) }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
  end
end
