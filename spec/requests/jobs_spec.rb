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
        check "job_blastn_job_attributes_filter"
        fill_in "job_blastn_job_attributes_expectation", :with => "5e-20"
        fill_in "job_blastn_job_attributes_min_bit_score", :with => "0"
        fill_in "job_blastn_job_attributes_max_score", :with => "25"
        select "Yes", :from => "job_blastn_job_attributes_gapped_alignments"
        select "11, 2", :from => "job_blastn_job_attributes_gap_opening_extension"

        # Blastx
        check "job_blastx_job_attributes_queue"
        select "tmp", :from => "job_blastx_job_attributes_blast_dbs"
        check "job_blastx_job_attributes_filter"
        fill_in "job_blastx_job_attributes_expectation", :with => "5e-20"
        fill_in "job_blastx_job_attributes_min_bit_score", :with => "0"
        fill_in "job_blastx_job_attributes_max_score", :with => "25"
        select "Yes", :from => "job_blastx_job_attributes_gapped_alignments"
        select "10, 2", :from => "job_blastx_job_attributes_gap_opening_extension"

        # Tblastn
        check "job_tblastn_job_attributes_queue"
        select "tmp", :from => "job_tblastn_job_attributes_blast_dbs"
        check "job_tblastn_job_attributes_filter"
        fill_in "job_tblastn_job_attributes_expectation", :with => "5e-20"
        fill_in "job_tblastn_job_attributes_min_bit_score", :with => "0"
        fill_in "job_tblastn_job_attributes_max_score", :with => "25"
        select "Yes", :from => "job_tblastn_job_attributes_gapped_alignments"
        select "9, 2", :from => "job_tblastn_job_attributes_gap_opening_extension"

        # Blastp
        check "job_blastp_job_attributes_queue"
        select "tmp", :from => "job_blastp_job_attributes_blast_dbs"
        check "job_blastp_job_attributes_filter"
        fill_in "job_blastp_job_attributes_expectation", :with => "5e-20"
        fill_in "job_blastp_job_attributes_min_bit_score", :with => "0"
        fill_in "job_blastp_job_attributes_max_score", :with => "25"
        select "Yes", :from => "job_blastp_job_attributes_gapped_alignments"
        select "13, 1", :from => "job_blastp_job_attributes_gap_opening_extension"

        click_button "Submit"

        page.should have_content("Search Results")

        click_link "Blastx"
        page.should have_content("Your search returned 0 hits.")

        click_link "Tblastn"
        page.should have_content("Your search returned 0 hits.")

        ## Interact with the Blast results. ##
        click_link "Blastn"

        # Render modal box.
        find("#blastn-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("qseq")
        page.should have_content("hseq")

        # Download sequence
        find("p.small a#download_sequence_1").click
        page.should have_content("Fetching sequence...")
        page.should have_content("Sequence Downloaded Successfully")

        click_link "Blastp"

        # Render modal box.
        find("#blastp-results").find("td a").click
        page.should have_content("Quorum Report Details")
        page.should have_content("qseq")
        page.should have_content("hseq")
      end
    end
    after(:all) do
      Capybara.use_default_driver
    end
  end

  describe "GET /quorum/jobs/id" do
    it "displays notice and renders form with invalid id" do
      visit job_path('12893479812347912')
      page.should have_content("The data you requested is unavailable. Please check your URL and try again.")
      current_path.should eq(new_job_path)
    end
  end

  describe "GET /quorum/jobs/id/get_quorum_search_results" do
    it "renders JSON results => false with invalid id" do
      visit "/quorum/jobs/23542352345/get_quorum_search_results.json"
      page.should have_content("[{\"results\":false}]")
    end
  end

  describe "GET /quorum/jobs/id/get_quorum_blast_hit_sequence" do
    it "renders empty JSON with invalid id" do
      visit "/quorum/jobs/23542352345/get_quorum_blast_hit_sequence.json"
      page.should have_content("[]")
    end

    it "renders empty JSON with invalid id and valid params" do
      visit "/quorum/jobs/23542352345/get_quorum_blast_hit_sequence.json?algo=blastn"
      page.should have_content("[]")
    end
  end
end
