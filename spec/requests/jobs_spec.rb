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

  describe "submit sequences in attached file" do
    it "check Blast algorithms and view query results" do
      visit new_job_path
      current_path.should eq(new_job_path)

      nucl_seqs = File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
      attach_file "job_sequence_file", nucl_seqs

      check "job_blastn_job_attributes_queue"
      select "tmp", :from => "job_blastn_job_attributes_blast_dbs" 

      check "job_blastx_job_attributes_queue"
      select "tmp", :from => "job_blastx_job_attributes_blast_dbs" 

      check "job_tblastn_job_attributes_queue"
      select "tmp", :from => "job_tblastn_job_attributes_blast_dbs" 

      check "job_blastp_job_attributes_queue"
      select "tmp", :from => "job_blastp_job_attributes_blast_dbs" 
      
      click_button "Submit"

      page.should have_content("Search Results") 
    end
  end

  describe "GET /quorum/jobs/unknown_id" do
    it "displays notice and renders form" do
      visit job_path('12893479812347912')
      page.should have_content("The data you requested is unavailable. Please check your URL and try again.")
      current_path.should eq(new_job_path)
    end
  end

end
