module Quorum
  class ApplicationController < ActionController::Base
    include Quorum::Helpers
    include Quorum::DataExport
  end
end
