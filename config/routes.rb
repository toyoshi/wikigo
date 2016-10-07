Rails.application.routes.draw do
  devise_for :users
  root to: 'words#show', id: '_main'
  resources :words, path: :wiki
end
