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
  get 'search/bento', to: 'search#bento', as: :search_bento
  get 'search/search_boxed', to: 'search#search_boxed'
  get 'search', to: 'search#search'

  get 'session/toggle_boxes', to: 'session#box_toggler'

  get 'feedback', to: 'feedback#index', as: :feedback
  post 'feedback', to: 'feedback#submit', as: :feedback_submit

  get 'item_status', to: 'aleph#item_status'
  get 'full_item_status', to: 'aleph#full_item_status'

  get 'hint', to: 'hint#hint'
  get 'toggle', to: 'feature#toggle'

  get 'record/(:db_source)/(:an)', to: 'record#record',
                                   as: :record,
                                   # Normal URL routing disallows periods in
                                   # parameters, but our accession numbers
                                   # actually include periods and we need them
                                   # to perform lookups. This constraint should
                                   # allow for all legal URL characters, except
                                   # those which are reserved.
                                   :constraints  => { :an => /[0-z\.\-\_~\(\)]+/ }

  get 'record/direct_link/(:db_source)/(:an)',
                                   to: 'record#direct_link',
                                   as: :record_direct_link,
                                   :constraints  => { :an => /[0-z\.\-\_~\(\)]+/ }

  match "/404", to: 'errors#not_found', :via => :all
  match "/418", to: 'errors#i_am_a_teapot', :via => :all
  get '*path', to: 'errors#not_found'
end
