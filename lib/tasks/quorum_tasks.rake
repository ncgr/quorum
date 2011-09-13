#
# Quourm Rake Tasks
#

namespace :quorum do
  namespace :blastdb do
    desc "Build Blast Database (options: DIR=/path/to/data " << 
    "{valid extensions: .tar.gz .tgz .tar.bz2 .tbz} " << 
    "-- separate multiple directories with a colon. " << 
    "TYPE={both}{prot}{nucl} -- defaults to both. " << 
    "PROT_FILE_NAME= -- defaults to peptides.fa. " <<
    "NUCL_FILE_NAME= -- defaults to contigs.fa. " <<
    "REBUILD_DB= {true or false} -- remove existing blast database(s). " <<
    "defaults to true)"
    task :build do
      include Blast

      @dir        = ENV['DIR'].split(':') unless ENV['DIR'].nil?
      @type       = ENV['TYPE'] || 'both'
      @prot_file  = ENV['PROT_FILE_NAME'] || 'peptides.fa'
      @nucl_file  = ENV['NUCL_FILE_NAME'] || 'contigs.fa'
      @rebuild_db = ENV['REBUILD_DB'] || true

      @blastdb_dir = "#{::Rails.root.to_s}/quorum/blastdb"
      @gff_dir     = "#{::Rails.root.to_s}/quorum/gff3"
      @log_dir     = "#{::Rails.root.to_s}/quorum/log"

      @type      = @type.downcase.strip
      @prot_file = @prot_file.downcase.strip
      @nucl_file = @nucl_file.downcase.strip

      unless Blast::VALID_TYPES.include?(@type)
        raise "Unknow type: #{@type}. Please provide one: both, nucl, or prot."
      end

      @nucl_file = "NULL" if @type == "prot"
      @prot_file = "NULL" if @type == "nucl"
      
      puts "Building your Blast database(s). This may take a while..."
      
      build_blast_db_data
      readme
    end
  end
end

module Blast

  # Valid values for @type.
  VALID_TYPES = ["both", "prot", "nucl"]

	# File bz2 and gz extensions.
	GZIP = /\.(tgz$)|(tar.gz$)/
	BZIP = /\.(tbz$)|(tar.bz2$)/
	
	#
	# Check build_blast_db dependencies.
	#
	def check_dependencies
	  @binaries = ["makeblastdb"]
	  @binaries.each do |b|
	    system("which #{b} >& /dev/null")
	    if $?.exitstatus > 0
	      raise "Dependency not found. Please add `#{b}` to your PATH."
	    end
	  end
	end
	
	#
	# Make Quorum directories.
	#
	def make_directories
    begin
	    `rm -rf #{@blastdb_dir}` if File.directory?(@blastdb_dir) && @rebuild_db
	    Dir.mkdir(@blastdb_dir)
	
	    `rm -rf #{@gff_dir}` if File.directory?(@gff_dir) && @rebuild_db
	    Dir.mkdir(@gff_dir)
	
	    Dir.mkdir(@log_dir) unless File.directory?(@log_dir)
    rescue SystemCallError => e
      puts e.message
      raise "Unable to make directory."
    end
	end
	
	#
	# Extracts and concatenates files from tarballs.
	#
	def extract_files(src, file, flag, path)
	  system("tar -x#{flag}Of #{src} #{file} >> #{path} 2>> \
	         #{@log_dir}/extract_data_error.log")
    if $?.exitstatus > 0
      raise "Data extraction error. " <<
        "See #{@log_dir}/extract_data_error.log for details."
    end
	end
	
	#
	# Execute makeblastdb on an extracted dataset.
	#
	def execute_makeblastdb(type, title, input)
    puts "Executing makeblastdb for #{title} dbtype #{type}..."
	  output = @blastdb_dir + "/" + title
	  system("makeblastdb \
	         -dbtype #{type} \
	         -title #{title} \
	         -in #{input} \
	         -out #{output} \
	         -hash_index >> #{@log_dir}/makeblastdb.log")
    if $?.exitstatus > 0
      raise "makeblastdb error. " <<
        "See #{@log_dir}/makeblastdb.log for details."
    end
	end
	
	#
	# Builds a Blast database from parse_blast_db_data.
	#
	def build_blast_db(blastdb, title)
	  contigs  = blastdb + "/contigs.fa"
	  peptides = blastdb + "/peptides.fa"

    found = false # set to true is data is found.

	  if File.exists?(contigs) && File.readable?(contigs)
	    execute_makeblastdb("nucl", title, contigs)
      found = true
    end
	  if File.exists?(peptides) && File.readable?(peptides)
	    execute_makeblastdb("prot", title, peptides)
      found = true
    end

    unless found
      raise "Extracted data not found for #{contigs} or #{peptides}. " <<
        "Make sure you supplied the correct data directory and file names."
    end
	end
	
	#
	# Parse Blast database data.
	#
	def build_blast_db_data
	  if @dir.blank?
	    raise "DIR must be set to continue. Execute `rake -D` for more information."
	  end
	
	  check_dependencies
	
	  make_directories
	  
	  @dir.each do |d|
	    unless File.directory?(d)    
	      raise "Directory not found: #{d}"
	    end
	
	    @data = Dir.glob("#{d}/*.{tgz,tar.gz,tbz,tar.bz2}")
	
	    if @data.blank?
	      raise "Data not found. Please check your directory and try " <<
	        "again.\nDirectory Entered: #{d}"
	    end
	
	    dataset = d.split('/').last
	    blastdb = @blastdb_dir + "/" + dataset
	    gff     = @gff_dir + "/" + dataset
	    Dir.mkdir(blastdb)
	    Dir.mkdir(gff)
	
	    @data.each do |s|
	      if s =~ GZIP
	        files = `tar -tzf #{s}` 
	        flag  = "z"
	      elsif s =~ BZIP
	        files = `tar -tjf #{s}`
	        flag  = "j"       
	      end
	      files = files.split(/\n/)
	      files.each do |f|
	        if f.include?(@prot_file)
	          extract_files(s, f, flag, blastdb + "/peptides.fa")
	        elsif f.include?(@nucl_file)
	          extract_files(s, f, flag, blastdb + "/contigs.fa")
	        elsif f.include?("gff")
	          extract_files(s, f, flag, gff + "/annots.gff")
          end
	      end
	    end
	    build_blast_db(blastdb, dataset)
	  end
	end

  #
  # Display BLAST_README
  #
  def readme
    file = File.readlines(File.dirname(__FILE__) + "/BLAST_README")
    file.each { |f| print f }
  end
end
