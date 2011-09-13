Quorum::Engine.routes.draw do
  resources :blasts, 
    :only => [:index, :show, :new, :create],
    :as => "blast"
  root :to => "blast#index"
end
