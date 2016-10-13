Rails.application.routes.draw do
  devise_for :users, path: '/-/users'
  root to: 'words#show', id: 1 # ID決め打ちは良くない
  resources :words, path: '/' 
  get '/-/index', to: 'words#index', as: 'words_index'
end
