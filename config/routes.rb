Quorum::Engine.routes.draw do
  resources :jobs, :only => [:index, :show, :new, :create] do
    member do
      get :get_quorum_search_results
      get :get_quorum_blast_hit_sequence
      get :send_quorum_blast_hit_sequence
    end
  end

  root :to => "jobs#index"
end
