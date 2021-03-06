Rails.application.routes.draw do
  concern :commentable do
    resources :comments, only: [:index, :new, :create]
  end

  concern :reportable do
    resources :reports, only: [:new, :create]
  end

  concern :subscribable do
    resource :subscription, only: [] do
      member do
        post :toggle
      end
    end
  end

  # Old forums subdomain
  match '*path', to: redirect('http://wallgig.net/forums'), via: :all, constraints: { subdomain: 'forums' }

  root 'wallpapers#index'

  # resources :groups do
  #   resources :collections

  #   resources :favourites

  #   member do
  #     get :apps
  #     patch :update_apps
  #     post :join
  #     delete :leave
  #   end
  # end

  # Categories
  resources :categories, only: [:index, :show]

  # Tags
  resources :tags, only: [:show] do
    concerns :subscribable
  end

  # Account
  namespace :account do
    # Collections
    resources :collections, except: :show do
      member do
        patch :move_up
        patch :move_down
      end

      resources :wallpapers
    end

    # Profile
    resource :profile do
      member do
        delete :remove_profile_cover
      end
    end

    # Settings
    resource :settings, only: [:edit, :update] do
      member do
        post :update_screen_resolution
      end
    end
  end

  # Collections
  resources :collections, only: [:index, :show] do
    concerns :subscribable
  end

  # Comments
  resources :comments, only: [:index, :edit, :update, :destroy] do
    concerns :reportable
    member do
      get :reply
    end
  end

  # Donations
  resources :donations, only: [:index] do
    member do
      patch :toggle_anonymous
    end
  end

  # Forums
  resources :forums, only: [:index, :show]

  # Notifications
  resources :notifications, only: [:index, :show] do
    collection do
      post :mark_all_read
      delete :purge
    end
  end

  # Search
  # get 'search/*query' => 'wallpapers#index'

  # Subscriptions
  resources :subscriptions, only: [:index, :show] do
    collection do
      get :collections
      get :tags
      post :mark_type_read
    end

    member do
      post :mark_read
    end
  end

  # Topics
  resources :topics do
    concerns :commentable
    concerns :reportable

    member do
      Topic::MODERATION_ACTIONS.each do |action_name|
        patch action_name
      end
    end
  end

  # Users
  devise_for :users

  resources :users, only: [:index, :show] do
    concerns :commentable
    concerns :subscribable

    resources :collections, only: [:index]
    resources :favourites,  only: [:index]
    resources :wallpapers, only: [:index]

    member do
      get :following
      get :followers
    end
  end

  # Wallpapers
  get 'w/:id' => 'wallpapers#show', id: /\d+/, as: :short_wallpaper
  resources :wallpapers do
    concerns :commentable
    concerns :reportable
    concerns :subscribable

    collection do
      post :save_search_params
    end

    member do
      get :collections
      post :toggle_collect
      post :toggle_favourite
      post :set_profile_cover
      get :history
      patch 'update_purity/:purity', action: :update_purity, as: :update_purity
      get ':width/:height' => 'wallpapers#show', width: /\d+/, height: /\d+/, as: :resized
    end
  end

  # API
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :categories, only: :index

      resources :collections, only: [] do
        resources :collections_wallpapers, path: 'wallpapers', only: [:create]
      end

      resources :notifications, only: :index do
        collection do
          get :unread
        end

        member do
          post :mark_read
        end
      end

      resources :sessions, only: :create

      resources :tags, only: [:index, :create] do
        collection do
          get :find
        end
      end

      resources :users, only: [:index] do
        collection do
          get :me
        end

        resources :collections, only: [:index, :create]
        resources :favourites, only: [:index]
      end

      resources :wallpapers, only: [:index, :show, :create] do
        resource :favourite do
          member do
            patch :toggle
          end
        end
      end
    end
  end

  # Oauth
  # use_doorkeeper

  # Developer routes
  scope path: '/monitoring' do
    authenticated :user, -> (u) { u.developer? } do
      mount Redmon::App => '/redmon'

      require 'sidekiq/web'
      require 'sidetiq/web'
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  # Admin routes
  scope path: '/admin' do
    authenticated :user, -> (u) { u.admin? } do
      mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'
    end
  end

  ActiveAdmin.routes(self)
end
