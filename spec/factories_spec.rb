require 'spec_helper'

FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "The #{factory_name} factory" do
    describe 'build method' do
      subject { build(factory_name) }
      it { should be_valid }
    end

    describe 'create method' do
      subject { create(factory_name) }
      it { should be_valid }
    end
  end
end
