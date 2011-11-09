Rails.application.routes.draw do

  mount Quorum::Engine => "/quorum"

  mount Resque::Server.new, :at => "/quorum/resque"

  match "/" => redirect("/quorum")

end
