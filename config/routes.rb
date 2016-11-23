Rails.application.routes.draw do
  resources :webhooks
  resources :attachments, path: '/-/attachments'

  namespace :site do
    get 'export'
    get 'settings'
    get 'activities'
    get 'members'
  end

  put 'site/update_settings'
  put 'site/update_user_role', as: 'update_user_role'
  put 'site/regenerate_token', as: 'regenerate_registration'

  devise_for :users, path: '/-/users', controllers: {
    registrations: 'users/registrations'
  }

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
