class WallpaperPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      _scope = scope.processed

      if user.nil?
        _scope.approved.sfw
      elsif user.moderator?
        _scope
      else
        _scope.approved
      end
    end
  end

  def show?
    return true if user.try(:moderator?)
    return record.sfw? if user.blank?
    record.approved?
  end

  def create?
    user.present? && record.user == user
  end

  def update?
    user.try(:moderator?)
  end

  def permitted_attributes
    attrs = [:purity, :image_gravity, :source, { tag_ids: [] }]
    attrs << :image unless record.persisted?
    attrs
  end
end
