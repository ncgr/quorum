module Quorum
  class ApplicationController < ActionController::Base
    include Quorum::System
    include Quorum::Helpers
  end
end
