Quorum::Engine.routes.draw do
  resources :blasts, :only => [:index, :show, :new, :create]
  resources :blast_reports, :only => [:show]

  root :to => "blasts#index"
end
