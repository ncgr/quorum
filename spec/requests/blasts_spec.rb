require 'spec_helper'

describe "Blasts" do
  describe "GET /" do
    it "redirects to new" do
      visit blasts_path
      current_path.should eq(new_blast_path)
    end
  end

  describe "submit empty form" do
    it "displays error and renders form" do
      visit new_blast_path
      current_path.should eq(new_blast_path)

      fill_in "blast_sequence", :with => ""
      click_button "Submit"

      page.should have_content("Please upload sequences in FASTA format.")
    end
  end

  describe "submit sequences in Word file" do
    it "displays error and renders form" do
      visit new_blast_path
      current_path.should eq(new_blast_path)

      word_file = File.expand_path("../../data/seqs.docx", __FILE__)
      attach_file "blast_sequence_file", word_file
      click_button "Submit"
      page.should have_content("Please enter your sequence(s) in Plain Text " << 
        "as FASTA.")
    end
  end

  describe "submit protein sequences in text area" do
    it "returns results" do
      visit new_blast_path
      current_path.should eq(new_blast_path)

      fill_in "blast_sequence", 
        :with => File.open(
          File.expand_path("../../data/prot_seqs.txt", __FILE__)
        ).read
      click_button "Submit"

      page.should have_content("Blast Results") 
    end
  end

  describe "submit peptide sequences in attached file" do
    it "set gapped alignment to 'yes' and optional params to defaults" do
      visit new_blast_path
      current_path.should eq(new_blast_path)

      prot_seqs = File.expand_path("../../data/prot_seqs.txt", __FILE__)
      attach_file "blast_sequence_file", prot_seqs
      fill_in "blast_expectation", :with => "5e-20"
      fill_in "blast_max_score", :with => 25
      fill_in "blast_min_bit_score", :with => 0
      select "Yes", :from => "blast_gapped_alignments"
      select "32767, 32767", :from => "blast_gap_opening_extension"
      click_button "Submit"

      page.should have_content("Blast Results") 

      click_link "ADA84676.1 protein L-isoaspartyl methyltransferase 1 [Cicer arietinum]"

      page.should have_content("ADA84676.1 protein L-isoaspartyl methyltransferase 1 [Cicer arietinum]")
      page.should have_content("Details")
      page.should have_content("Alignment")

      click_link "Back"

      page.should have_content("Blast Results")

    end
  end

  describe "nucleic acid sequences in attached file" do
    it "set optional params to defaults and view query results" do
      visit new_blast_path
      current_path.should eq(new_blast_path)

      nucl_seqs = File.expand_path("../../data/nucl_seqs.txt", __FILE__)
      attach_file "blast_sequence_file", nucl_seqs
      fill_in "blast_expectation", :with => "5e-20"
      fill_in "blast_max_score", :with => 25
      fill_in "blast_min_bit_score", :with => 0
      select "Yes", :from => "blast_gapped_alignments"
      select "10, 2", :from => "blast_gap_opening_extension"
      click_button "Submit"

      page.should have_content("Blast Results") 

      click_link "TOG900080"

      page.should have_content("TOG900080")
      page.should have_content("Details")
      page.should have_content("Alignment")

      click_link "Back"

      page.should have_content("Blast Results")

    end

  end
end
