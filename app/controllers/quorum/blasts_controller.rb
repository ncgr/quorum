module Quorum
  class BlastsController < ApplicationController

    def index
      redirect_to :action => "new"
    end

    def new
      @quorum = Quorum.new
    end

    def create

    end

    def show

    end
  end
end
