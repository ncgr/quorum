require 'spec_helper'
require 'generators/templates/logger'

describe "Quorum::Logger" do
  describe "#log" do
    before(:all) do
      @args   = File.join(::Rails.root.to_s, "log") 
      @logger = Quorum::Logger.new(@args)
    end

    it "records program and message in a log file" do
      @logger.log("RSpec", "This is a test.")

      File.size(
        File.join(@args, "quorum.log")
      ).should be > 0

      `rm #{File.join(@args, "quorum.log")}`
    end

    it "records program, message, exits and removes files" do
      lambda {
        @logger.log(
          "RSpec", "This is a test.", 1, 
          File.join(@args, "quorum.log")
        )
      }.should raise_error(SystemExit)

      File.exists?(
        File.join(@args, "quorum.log")
      ).should be_false

    end
  end  
end
