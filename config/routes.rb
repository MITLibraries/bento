Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  mount Flipflop::Engine => "/flipflop"

  root to: 'search#index'
  get 'search/index', to: 'search#index'
  get 'search/bento', to: 'search#bento', as: :search_bento
  get 'search/search_boxed', to: 'search#search_boxed'
  get 'search', to: 'search#search'

  get 'session/toggle_boxes', to: 'session#box_toggler'

  get 'suggested_resources', to: 'tacos#suggested_resources'
  get 'toggle', to: 'feature#toggle'
  get 'full_record_toggle', to: 'feature#full_record_toggle'

  # The two record controller routes exist solely to redirect full record links, which were once considered permalinks, 
  # to their corresponding Primo records. This is why they now route to the same method, because they do the same thing.
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
                                   to: 'record#record',
                                   as: :record_direct_link,
                                   :constraints  => { :an => /[0-z\.\-\_~\(\)]+/ }

  match "/404", to: 'errors#not_found', :via => :all
  match "/418", to: 'errors#i_am_a_teapot', :via => :all
  get '*path', to: 'errors#not_found'
end
