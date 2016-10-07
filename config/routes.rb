Rails.application.routes.draw do
  devise_for :users
  root to: 'words#show', id: 1
  resources :words, path: :wiki
end
