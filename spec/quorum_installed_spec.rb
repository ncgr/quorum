require 'spec_helper'

describe "Quorum" do
  before(:all) do
    @dummy_path = File.expand_path("../dummy/", __FILE__)
  end

  it "checks for generated config file" do
    File.exists?(
      File.join(@dummy_path, "config", "quorum_settings.yml")
    ).should be_true
  end

  it "checks for generated initializer" do
    File.exists?(
      File.join(@dummy_path, "config", "initializers", "quorum_initializer.rb")
    ).should be_true
  end

  it "checks for generated locale" do
    File.exists?(
      File.join(@dummy_path, "config", "locales", "quorum.en.yml")
    ).should be_true
  end

  it "checks for quorum directory" do
    File.directory?(File.join(@dummy_path, "quorum")).should be_true
  end

  it "checks for quorum/lib files" do
    File.exists?(
      File.join(@dummy_path, "quorum", "lib", "search_tools", "blast.rb")
    ).should be_true

    File.exists?(
      File.join(@dummy_path, "quorum", "lib", "logger.rb")
    ).should be_true

    File.exists?(
      File.join(@dummy_path, "quorum", "lib", "trollop.rb")
    ).should be_true
  end

  it "checks for quorum/bin files and ensures they are executable" do
    File.exists?(
      File.join(@dummy_path, "quorum", "bin", "search")
    ).should be_true

    File.executable?(
      File.join(@dummy_path, "quorum", "bin", "search")
    ).should be_true
  end

  it "checks for generated directories" do
    File.directory?(File.join(@dummy_path, "quorum", "log")).should be_true

    File.directory?(File.join(@dummy_path, "quorum", "tmp")).should be_true
  end

  it "ensures Quorum::Engine is mounted in dummy/config/routes.rb" do
    f = File.open(File.join(@dummy_path, "config", "routes.rb"), "r")
    f.read.include?("mount Quorum::Engine => \"/quorum\"").should be_true
  end

  it "ensures Resque::Server is mounted in dummy/config/routes.rb" do
    f = File.open(File.join(@dummy_path, "config", "routes.rb"), "r")
    f.read.include?("mount Resque::Server.new, :at => \"/quorum/resque\"").should be_true
  end
end
