Quorum::Engine.routes.draw do
  resources :jobs, :only => [:index, :show, :new, :create]

  root :to => "jobs#index"
end
