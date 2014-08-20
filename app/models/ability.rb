# Reference: https://github.com/ryanb/cancan/wiki/Defining-Abilities
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.admin?
      can :manage, :all
    end

    # Collection
    can :read, Collection, public: true

    # Comment
    can :read, Comment

    # Favourite
    can :read, Favourite, wallpaper: { processing: false, purity: 'sfw' }

    # User
    can :read, User

    # Group
    can :read, Group, access: ['public', 'private']

    # Forum
    can :read, Forum, can_read: true

    # Topic
    can :read, Topic, forum: { can_read: true }, hidden: false

    # Tag
    can :read, Tag

    if user.persisted?
      # Wallpaper
      can    :read, Wallpaper, processing: false
      cannot :read, Wallpaper, approved_at: nil unless user.moderator?
      can :create, Wallpaper, user_id: user.id
      can :set_profile_cover, Wallpaper, purity: 'sfw'
      # can :crud, Wallpaper, user_id: user.id

      # Favourite
      can :crud, Favourite, user_id: user.id

      # Collection
      can :crud, Collection, user_id: user.id

      # Comment
      can :crud, Comment, user_id: user.id
      cannot [:update, :destroy], Comment do |comment|
        # 15 minutes to destroy a comment
        Time.now - comment.created_at > 15.minutes
      end unless user.moderator?
      can :update, Comment, commentable_type: 'Topic', user_id: user.id

      # User
      can :crud, User, id: user.id

      # Group
      can :crud, Group, owner_id: user.id

      can :join, Group, access: 'public'
      cannot :join, Group, users_groups: { user_id: user.id }

      can :leave, Group, users_groups: { user_id: user.id }
      cannot :leave, Group, owner_id: user.id

      # Forum
      can :post, Forum, can_post: true

      # Report
      can :create, Report

      # Topic
      can :create,  Topic, forum: { can_post: true }
      can :comment, Topic, forum: { can_comment: true }, locked: false
      can :update,  Topic, user_id: user.id

      # Tag
      can :create, Tag, coined_by_id: user.id

      # Subscription
      can :crud, Subscription, user_id: user.id
      can :subscribe, :all
      cannot :subscribe, Collection, user_id: user.id
      cannot :subscribe, User, id: user.id

      # Moderators
      if user.moderator?
        can :manage, Category
        can :manage, Comment
        can :manage, Report
        can :manage, Tag
        can :manage, Topic
        can :manage, Wallpaper
        can :manage, ActiveAdmin::Comment
        can :read, ActiveAdmin::Page, name: 'Dashboard'
      end
    else
      # Wallpaper
      can :read, Wallpaper, processing: false, purity: 'sfw'
    end
  end
end