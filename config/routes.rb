Rails.application.routes.draw do
  devise_for :users, path: '/-/users'
  root to: 'words#show', id: 1 # ID決め打ちは良くない
  get '/-/index', to: 'words#index', as: 'words_index'
  resources :words, path: '/' do
  end
  get '/:id/version/:version', to: 'words#version', as: 'word_version'
end
