Quorum::Engine.routes.draw do
  resources :jobs, :only => [:index, :show, :new, :create] do
    member do
      get :search, :defaults => { :format => 'json' }
      get :get_blast_hit_sequence, :defaults => { :format => 'json' }
      get :send_blast_hit_sequence
    end
  end

  root :to => "jobs#index"
end
