Rails.application.routes.draw do
  # Health check endpoint for deploy orchestrators and load balancers —
  # the same route the Rails 8 app template ships (#111). Renders 200 "OK"
  # when the app is up; Kamal's proxy polls it before cutting traffic over.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Sitemap
  get '/sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }
  
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
    delete 'site/reset_content', as: 'reset_content'

    resources :api_tokens, only: [:index, :create, :destroy]
    resources :webhooks, except: [:show]

  end

  # Sign in/out and password reset (#110): the Rails 8 authentication
  # generator's controllers on top of ActiveModel's has_secure_password
  # replace Devise. The view-facing helper names (new_user_session_path,
  # destroy_user_session_path) are kept stable so the layouts didn't churn.
  get    'signin',   to: 'sessions#new',     as: :new_user_session
  post   'signin',   to: 'sessions#create'
  delete 'signout',  to: 'sessions#destroy', as: :destroy_user_session
  resources :passwords, param: :token, only: %i[new create edit update]

  # Invitation-token-gated sign up (custom flow, predates this app's Devise)
  resource :user_registration, controller: 'users/registrations',
    path: 'users/registration', only: %i[new create edit update]

  root to: 'words#show', id: 1

  get '/-/index', to: 'words#index', as: 'words_index'
  get '/tags', to: 'words#tags', as: 'tags_index'
  get '/tag::tag_list', to: 'words#tag', as: 'word_tag'

  resources :words, path: '/' do
    member do
      post :ai_edit
    end
    get '/versions', to: redirect('/%{word_id}/versions/0')
    resources :versions, only: [:show] do
      member do
        patch :rollback, to: 'versions#rollback'
      end
    end
  end

  #get '/:id/version/:version', to: 'words#version', as: 'word_version'
end
