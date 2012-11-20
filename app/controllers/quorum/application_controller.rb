module Quorum
  class ApplicationController < ActionController::Base
    include Quorum::Helpers
    include Quorum::Sequence::SendSequence
  end
end
