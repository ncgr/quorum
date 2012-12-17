require 'spec_helper'

describe "Jobs" do
  describe "GET /" do
    it "redirects to new" do
      visit jobs_path
      current_path.should eq(new_job_path)
    end
  end

  describe "submit empty form" do
    it "displays error and renders form" do
      visit new_job_path
      current_path.should eq(new_job_path)

      fill_in "job_sequence", :with => ""
      click_button "Submit"

      page.should have_content("Please enter your sequence(s) in Plain Text " <<
                               "as FASTA.")
    end
  end

  describe "submit sequences in Word file" do
    it "displays error and renders form" do
      visit new_job_path
      current_path.should eq(new_job_path)

      word_file = File.expand_path("../../data/seqs.docx", __FILE__)
      attach_file "job_sequence_file", word_file
      click_button "Submit"
      page.should have_content("Please enter your sequence(s) in Plain Text " <<
                               "as FASTA.")
    end
  end

  describe "submit sequences not in FASTA format" do
    it "displays error and renders form" do
      visit new_job_path
      current_path.should eq(new_job_path)

      file = File.expand_path("../../data/seqs_not_fa.txt", __FILE__)
      attach_file "job_sequence_file", file
      click_button "Submit"
      page.should have_content("Please enter your sequence(s) in Plain Text " <<
                               "as FASTA.")
    end
  end

  context "javascript", @javascript do
    before(:all) do
      Capybara.default_wait_time = 5
      Capybara.server_port       = 53331
      Capybara.current_driver    = :selenium
    end
    before(:each) do
      ActiveRecord::Base.observers.enable Quorum::JobQueueObserver
      ResqueSpec.reset!
      ResqueSpec.inline = true
    end
    describe "submit sequences in attached file" do
      it "check algorithms, fill in values, view results and download hit sequence" do
        visit new_job_path
        current_path.should eq(new_job_path)

        nucl_seqs = File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
        attach_file "job_sequence_file", nucl_seqs

        # Blastn
        check "job_blastn_job_attributes_queue"
        select "tmp", :from => "job_blastn_job_attributes_blast_dbs"
        select "Yes", :from => "job_blastn_job_attributes_filter"
        fill_in "job_blastn_job_attributes_expectation", :with => "5e-20"
        fill_in "job_blastn_job_attributes_min_bit_score", :with => "0"
        fill_in "job_blastn_job_attributes_max_target_seqs", :with => "25"
        select "Yes", :from => "job_blastn_job_attributes_gapped_alignments"
        select "11, 2", :from => "job_blastn_job_attributes_gap_opening_extension"

        # Blastx
        check "job_blastx_job_attributes_queue"
        select "tmp", :from => "job_blastx_job_attributes_blast_dbs"
        select "Yes", :from => "job_blastx_job_attributes_filter"
        fill_in "job_blastx_job_attributes_expectation", :with => "5e-20"
        fill_in "job_blastx_job_attributes_min_bit_score", :with => "0"
        fill_in "job_blastx_job_attributes_max_target_seqs", :with => "25"
        select "Yes", :from => "job_blastx_job_attributes_gapped_alignments"
        select "10, 2", :from => "job_blastx_job_attributes_gap_opening_extension"

        # Tblastn
        check "job_tblastn_job_attributes_queue"
        select "tmp", :from => "job_tblastn_job_attributes_blast_dbs"
        select "Yes", :from => "job_tblastn_job_attributes_filter"
        fill_in "job_tblastn_job_attributes_expectation", :with => "5e-20"
        fill_in "job_tblastn_job_attributes_min_bit_score", :with => "0"
        fill_in "job_tblastn_job_attributes_max_target_seqs", :with => "25"
        select "Yes", :from => "job_tblastn_job_attributes_gapped_alignments"
        select "9, 2", :from => "job_tblastn_job_attributes_gap_opening_extension"

        # Blastp
        check "job_blastp_job_attributes_queue"
        select "tmp", :from => "job_blastp_job_attributes_blast_dbs"
        select "No", :from => "job_blastp_job_attributes_filter"
        fill_in "job_blastp_job_attributes_expectation", :with => "5e-20"
        fill_in "job_blastp_job_attributes_min_bit_score", :with => "0"
        fill_in "job_blastp_job_attributes_max_target_seqs", :with => "25"
        select "Yes", :from => "job_blastp_job_attributes_gapped_alignments"
        select "13, 1", :from => "job_blastp_job_attributes_gap_opening_extension"

        # Gmap
        check "job_gmap_job_attributes_queue"
        select "tmp", :from => "job_gmap_job_attributes_gmap_dbs"
        select "Yes", :from => "job_gmap_job_attributes_splicing"
        fill_in "job_gmap_job_attributes_intron_len", :with => "1000000"
        fill_in "job_gmap_job_attributes_total_len", :with => "2400000"
        fill_in "job_gmap_job_attributes_chimera_margin", :with => "40"
        select "No pruning", :from => "job_gmap_job_attributes_prune_level"

        click_button "Submit"

        page.should have_content("Search Results")

        click_link "Blastx"

        # Render modal box.
        find("#blastx-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("qseq")
        page.should have_content("hseq")

        click_link "Tblastn"

        # Render modal box.
        find("#tblastn-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("qseq")
        page.should have_content("hseq")

        ## Interact with the Blast results. ##
        click_link "Blastn"

        # Render modal box.
        find("#blastn-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("qseq")
        page.should have_content("hseq")

        # Download sequence
        find("p.small a.download_sequence").click
        page.should have_content("Fetching sequence...")
        page.should have_content("Sequence Downloaded Successfully")

        click_link "Blastp"

        # Render modal box.
        find("#blastp-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("qseq")
        page.should have_content("hseq")

        click_link "Gmap"

        # Render modal box.
        find("#gmap-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("seq")

      end
    end
    after(:all) do
      Capybara.use_default_driver
      ActiveRecord::Base.observers.disable :all
    end
  end

  describe "GET /quorum/jobs/id" do
    it "displays notice and renders form with invalid id" do
      visit job_path('12893')
      page.should have_content("The data you requested is unavailable. Please check your URL and try again.")
      current_path.should eq(new_job_path)
    end
  end

  describe "GET /quorum/jobs/id/search" do
    it "renders JSON results => false with invalid id" do
      visit "/quorum/jobs/23542/search.json"
      page.should have_content("[{\"results\":false}]")
    end
  end

  describe "GET /quorum/jobs/id/get_blast_hit_sequence" do
    it "renders empty JSON with invalid id" do
      visit "/quorum/jobs/23542/get_blast_hit_sequence.json"
      page.should have_content("[]")
    end

    it "renders empty JSON with invalid id and valid params" do
      visit "/quorum/jobs/23542/get_blast_hit_sequence.json?algo=blastn"
      page.should have_content("[]")
    end
  end

  describe "GET /quorum/jobs/id/send_blast_hit_sequence" do
    it "renders empty text on error" do
      visit "/quorum/jobs/23423/send_blast_hit_sequence?meta_id=1231"
      page.should_not have_content(" ")
    end
  end
end
