Rails.application.routes.draw do
  mount Flipflop::Engine => "/flipflop"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users, :controllers => {
    :omniauth_callbacks => 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'search#index'
  get 'search/index', to: 'search#index'
  get 'search/bento', to: 'search#bento'
  get 'search/search_boxed', to: 'search#search_boxed'
  get 'search', to: 'search#search'

  get 'session/toggle_boxes', to: 'session#box_toggler'

  get 'feedback', to: 'feedback#index', as: :feedback
  post 'feedback', to: 'feedback#submit', as: :feedback_submit

  get 'item_status', to: 'aleph#item_status'
  get 'toggle', to: 'feature#toggle'

  get '/broken', to: 'catch_all#broken_intentionally'
  get '*path', to: 'catch_all#catch_all'
end
