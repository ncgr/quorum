namespace :quorum do
  namespace :blastdb do
    desc "Build BlastDB (options: DIR=/path/to/data " << 
    "{valid extensions: .tar.gz .tgz .tar.bz2 .tbz} " << 
    "-- separate multiple directories with a colon. " << 
    "TYPE={both}{prot}{nucl} -- defaults to both. " << 
    "PROT_FILE_NAME= -- defaults to peptides.fa. " <<
    "NUCL_FILE_NAME= -- defaults to contigs.fa)"
    task :build do
      @dir       = ENV['DIR'].split(':') unless ENV['DIR'].nil?
      @type      = ENV['TYPE'] || 'both'
      @prot_file = ENV['PROT_FILE_NAME'] || 'peptides.fa'
      @nucl_file = ENV['NUCL_FILE_NAME'] || 'contigs.fa'

      @blastdb_dir = "#{::Rails.root.to_s}/quorum/blastdb"
      @gff_dir     = "#{::Rails.root.to_s}/quorum/gff3"

      @type.strip!.downcase!
      @prot_file.strip!.downcase!
      @nucl_file.strip!.downcase!

      build_blast_db
    end
  end
end

GZIP = /\.(tgz)|(tar.gz)/
BZIP = /\.(tbz)|(tar.bz2)/

#
# Check build_blast_db dependencies.
#
def check_dependencies
  @binaries = ["makeblastdb"]
  @binaries.each do |b|
    system("which #{b}")
    if $?.exitstatus > 0
      raise "Rake task dependency not found. Please add `#{b}` to your PATH."
    end
  end
end

#
# Builds a Blast database from the rake task args.
#
def build_blast_db
  if @dir.blank?
    raise "DIR must be set to continue. Execute `rake -D` for more information."
  end

  check_dependencies
  
  Dir.delete(@blastdb_dir) if File.directory?(@blastdb_dir)
  Dir.mkdir(@blastdb_dir)

  Dir.delete(@gff_dir) if File.directory?(@gff_dir)
  Dir.mkdir(@gff_dir)

  @dir.each do |d|
    unless File.directory?(d)    
      raise "Directory not found: #{d}"
    end

    @data = Dir["#{d}/*.{tgz, tar.gz, tbz, tar.bz2}"]

    if @data.blank?
      raise "Data not found. Please check your directory and try " <<
        "again.\nDirectory Entered: #{d}"
    end

    dataset = d.split('/').last
    blastdb = @blastdb_dir + "/" + dataset
    gff     = @gff_dir + "/" + dataset
    Dir.mkdir(blastdb)
    Dir.mkdir(gff)

     

  end
end
