module Quorum
  class ApplicationController < ActionController::Base

    include Quorum::Helpers
    include Quorum::System

  end
end
