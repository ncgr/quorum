Quorum::Engine.routes.draw do
  resources :blasts, :only => [:index, :show, :new, :create]

  root :to => "blasts#index"
end
