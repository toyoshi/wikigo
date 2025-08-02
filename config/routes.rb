Rails.application.routes.draw do
  # API Routes
  namespace :api do
    namespace :v1 do
      resources :words do
        collection do
          get :search
          get :tags
        end
      end
      get 'words/tagged/:tag', to: 'words#tagged', as: 'words_tagged'
    end
  end

  # Web Routes
  resources :attachments, path: '/-/attachments'

  scope :settings do
    namespace :site do
      get 'export'
      post 'import'

      get 'settings'
      get 'activities'
      get 'members'
    end

    put 'site/update_settings'
    put 'site/update_user_role', as: 'update_user_role'
    put 'site/regenerate_token', as: 'regenerate_registration'

    resources :api_tokens, only: [:index, :create, :destroy]
    resources :webhooks, except: [:show]

    devise_for :users, skip: :registrations
    devise_scope :user do
      resource :registration,
        only: [:new, :create, :edit, :update],
        path: 'users',
        path_names: { new: 'sign_up' },
        controller: 'users/registrations',
        as: :user_registration do
          get :cancel
        end
    end
  end

  root to: 'words#show', id: 1 # ID決め打ちは良くない

  get '/-/index', to: 'words#index', as: 'words_index'
  get '/tags', to: 'words#tags', as: 'tags_index'
  get '/tag::tag_list', to: 'words#tag', as: 'word_tag'

  resources :words, path: '/' do
    get '/versions', to: redirect('/%{word_id}/versions/0')
    resources :versions, only: [:show] do
      member do
        patch :rollback, to: 'versions#rollback'
      end
    end
  end

  #get '/:id/version/:version', to: 'words#version', as: 'word_version'
end
