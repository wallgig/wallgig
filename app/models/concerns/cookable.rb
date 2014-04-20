module Cookable
  extend ActiveSupport::Concern

  module ClassMethods
    def cookable(*cookables)
      cookables.each do |cookable|
        before_save do
          self[:"cooked_#{cookable}"] = ApplicationController.helpers.markdown(self[cookable]) if send(:"#{cookable}_changed?")
        end
      end
    end
  end
end
