Quorum::Engine.routes.draw do
  resources :jobs, :only => [:index, :show, :new, :create] do
    member do
      get :get_quorum_search_results
    end
  end

  root :to => "jobs#index"
end
