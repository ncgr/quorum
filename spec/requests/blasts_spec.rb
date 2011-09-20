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

  describe "submit protein sequence and choose nucleic_acid" do
    it "returns zero hits" do
      visit new_blast_path
      current_path.should eq(new_blast_path)

      choose "blast_sequence_type_nucleic_acid"
      prot_seqs = File.expand_path("../../data/prot_seqs.txt", __FILE__)
      attach_file "blast_sequence_file", prot_seqs
      click_button "Submit"

      current_path.should eq(new_blast_path)

      page.should have_content("Your search returned 0 hits.")
    end
  end

end
