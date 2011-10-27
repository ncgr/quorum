require 'spec_helper'
require 'generators/templates/blast'

# Let the request specs handle Quorum::SearchTools
describe "Quorum::SearchTools::Blast" do
  describe "#execute_blast" do
    before(:all) do
      @sequence = File.open(
        File.expand_path('../../data/nucl_seqs.txt', __FILE__)
      ).read

      # Set args as though we executed option_parser.
      args = {
        :id             => 1,
        :log_directory  => File.join(::Rails.root.to_s, 'quorum', 'log'),
        :tmp            => File.join(::Rails.root.to_s, 'quorum', 'tmp'),
        :blast_database => File.join(::Rails.root.to_s, 'quorum', 'blastdb'),
        :blast_threads  => 1,
        :tblastn        => "tmp",
        :blastp         => "tmp",
        :blastn         => "tmp",
        :blastx         => "tmp",
      }

      @blast = Quorum::SearchTools::Blast.new(args)
    end
  end
end
