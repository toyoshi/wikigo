Rails.application.routes.draw do
  devise_for :users, path: '/-/users'
  root to: 'words#show', id: 1
  resources :words, path: '/' 
end
