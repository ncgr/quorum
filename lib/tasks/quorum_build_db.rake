#
# Quourm Build Blast DBs
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'build'))

require 'db'

namespace :quorum do
  namespace :blastdb do
    desc "Build Blast Database (options: DIR=/path/to/data " <<
    "{valid extensions: .tar.gz .tgz .tar.bz2 .tbz} " <<
    "-- separate multiple directories with a colon. " <<
    "TYPE={both}{prot}{nucl} -- defaults to both. " <<
    "PROT_FILE_NAME= -- defaults to peptides.fa. " <<
    "NUCL_FILE_NAME= -- defaults to contigs.fa. " <<
    "REBUILD_DB= {true or false} -- remove existing blast database(s). " <<
    "Defaults to false. " <<
    "EMPTY={true or false} -- skip makeblastdb and create empty " <<
    "directories. Use this option if you prefer to create your own " <<
    "Blast database. Defaults to false.)"
    task :build do

      args = {}

      args[:dir]        = ENV['DIR']
      args[:type]       = ENV['TYPE'] || 'both'
      args[:prot_file]  = ENV['PROT_FILE_NAME'] || 'peptides.fa'
      args[:nucl_file]  = ENV['NUCL_FILE_NAME'] || 'contigs.fa'
      args[:rebuild_db] = ENV['REBUILD_DB'] || false
      args[:empty]      = ENV['EMPTY'] || false

      args[:blastdb_dir] = File.join(::Rails.root.to_s, "quorum", "blastdb")
      args[:gff_dir]     = File.join(::Rails.root.to_s, "quorum", "gff3")
      args[:log_dir]     = File.join(::Rails.root.to_s, "quorum", "log")

      args[:type]      = args[:type].downcase.strip
      args[:prot_file] = args[:prot_file].downcase.strip
      args[:nucl_file] = args[:nucl_file].downcase.strip
      args[:nucl_file] = "NULL" if args[:type] == "prot"
      args[:prot_file] = "NULL" if args[:type] == "nucl"

      unless args[:empty]
        puts "Building your Blast database(s). This may take a while..."
      end

      Quorum::Db::Blast.new(args).build_blast_db_data
    end
  end

  namespace :gmapdb do
    desc "Build GMAP Database (options: DIR=/path/to/data " <<
    "{valid extensions: .fa .fa.gz} " <<
    "-- separate multiple directories with a colon. " <<
    "REBUILD_DB={true of false} -- remove existing gmap database(s). " <<
    "Defaults to false."
    "EMPTY={true or false} -- skip gmap_build and create empty directory. " <<
    "Use this option if you prefer to create your own GMAP database. " <<
    "Defaults to false.)"
    task :build do

      args = {}

      args[:dir]        = ENV['DIR']
      args[:rebuild_db] = ENV['REBUILD_DB'] || false
      args[:empty]      = ENV['EMPTY'] || false
      args[:gmapdb_dir] = File.join(::Rails.root.to_s, "quorum", "gmapdb")
      args[:log_dir]    = File.join(::Rails.root.to_s, "quorum", "log")

      unless args[:empty]
        puts "Building your GMAP database(s). This may take a while..."
      end

      Quorum::Db::Gmap.new(args).build_gmap_db_data
    end
  end
end

