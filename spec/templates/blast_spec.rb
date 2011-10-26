require 'spec_helper'
require 'generators/templates/blast'

describe "Quorum::SearchTools::Blast" do
  describe "simulate Blast" do
    before(:each) do
      # Set args as though we executed option_parser.
      @args = {
        :id             => 1,
        :log_directory  => "/path/to/log_directory",
        :tmp            => "/tmp",
        :blast_database => "/path/to/blastdb",
        :blast_threads  => 1,
        :tblastn        => "test",
        :blastp         => "test",
        :blastn         => "test",
        :blastx         => "test",
      }
    end

  end
end
