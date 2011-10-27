require 'spec_helper'
require 'quorum/system'

include Quorum::System

describe "Quorum::System" do
  describe "#execute_cmd" do
    before(:all) do
      @args = {
        :cmd      => "whoami >& /dev/null",
        :remote   => false,
        :ssh_host => "example.com",
        :ssh_user => "user"
      }
    end

    it "executes cmd locally via Kernel#system when remote = false" do
      execute_cmd(
        @args[:cmd], @args[:remote], @args[:ssh_host], @args[:ssh_user]
      ).should eq(:error_0)
    end
  end
end
