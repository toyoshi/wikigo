Rails.application.routes.draw do
  get 'site/settings'
  put 'site/update_settings'

  get 'site/members'
  put 'site/regenerate_token', as: 'regenerate_registration'

  devise_for :users, path: '/-/users', controllers: {
    registrations: 'users/registrations'
  }

  root to: 'words#show', id: 1 # ID決め打ちは良くない
  get '/-/index', to: 'words#index', as: 'words_index'
  resources :words, path: '/' do
  end
  get '/:id/version/:version', to: 'words#version', as: 'word_version'
end
