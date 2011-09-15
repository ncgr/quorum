Rails.application.routes.draw do

  mount Quorum::Engine => "/quorum"

  match "/" => redirect("/quorum")

end
