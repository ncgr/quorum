module Quorum
  #
  # Build Blast Database(s)
  #
  class BuildBlastDB

    # Valid values for @type.
    VALID_TYPES = ["both", "prot", "nucl"]

    # Blast dependencies
    DEPENDENCIES = ["makeblastdb"]

    # File bz2 and gz extensions.
    GZIP = /\.(tgz$)|(tar.gz$)/
    BZIP = /\.(tbz$)|(tar.bz2$)/

    private

    def initialize(args, output = $stdout)
      @dir         = args[:dir]
      @type        = args[:type]
      @prot_file   = args[:prot_file]
      @nucl_file   = args[:nucl_file]
      @rebuild_db  = args[:rebuild_db]
      @empty       = args[:empty]
      @blastdb_dir = args[:blastdb_dir]
      @gff_dir     = args[:gff_dir]
      @log_dir     = args[:log_dir]

      @output = output
    end

    #
    # Check build_blast_db dependencies.
    #
    def check_dependencies
      DEPENDENCIES.each do |b|
        system("which #{b} > /dev/null 2>&1")
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
        Dir.mkdir(@blastdb_dir) unless File.directory?(@blastdb_dir)

        `rm -rf #{@gff_dir}` if File.directory?(@gff_dir) && @rebuild_db
        Dir.mkdir(@gff_dir) unless File.directory?(@gff_dir)

        Dir.mkdir(@log_dir) unless File.directory?(@log_dir)
      rescue SystemCallError => e
        @output.puts e.message
        raise "Unable to make directory. " << 
          "Perhaps you forgot to execute the quorum initializer. \n\n" <<
          "rails generate quorum:install"
      end
    end

    #
    # Create directories per tarball and return tarball file name 
    # minus the file extension.
    #
    def create_file_name(file, base_dir)
      file_name = file.split("/").delete_if { |f| f.include?(".") }.first
      unless File.exists?(File.join(base_dir, file_name))
        Dir.mkdir(File.join(base_dir, file_name))
      end
      file_name
    end

    #
    # Extracts and concatenates files from tarballs.
    #
    def extract_files(src, file, flag, path)
      extract_data_error = File.join(@log_dir, "extract_data_error.log")

      cmd = "tar -x#{flag}Of #{src} #{file} >> #{path} 2>> " <<
        "#{extract_data_error}"
      system(cmd)
      if $?.exitstatus > 0
        raise "Data extraction error. " <<
          "See #{extract_data_error} for details."
      end
    end

    #
    # Execute makeblastdb on an extracted dataset.
    #
    def execute_makeblastdb(type, title, input)
      @output.puts "Executing makeblastdb for #{title} dbtype #{type}..."

      makeblast_log = File.join(@log_dir, "makeblastdb.log")
      output        = File.dirname(input)

      cmd = "makeblastdb " <<
        "-dbtype #{type} " <<
        "-title #{title} " <<
        "-in #{input} " <<
        "-out #{output} " <<
        "-hash_index >> #{makeblast_log}"
      system(cmd)
      if $?.exitstatus > 0
        raise "makeblastdb error. " <<
          "See #{makeblast_log} for details."
      end
    end

    #
    # Builds a Blast database from parse_blast_db_data.
    #
    def build_blast_db(blastdb)
      Dir.glob(File.expand_path(blastdb) + "/*").each do |d|
        if File.directory?(d)
          contigs  = File.join(d, "contigs.fa")
          peptides = File.join(d, "peptides.fa")

          found = false 

          if File.exists?(contigs) && File.readable?(contigs)
            execute_makeblastdb("nucl", d, contigs)
            found = true
          end
          if File.exists?(peptides) && File.readable?(peptides)
            execute_makeblastdb("prot", d, peptides)
            found = true
          end

          unless found
            raise "Extracted data not found for #{contigs} or #{peptides}. " <<
            "Make sure you supplied the correct data directory and file names."
          end
        end
      end
    end

    #
    # Display BLAST_README
    #
    def readme
      file = File.readlines(File.join(File.dirname(__FILE__), "README"))
      file.each { |f| @output.print f }
    end

    public

    #
    # Parse Blast database data.
    #
    def build_blast_db_data
      # Create necessary directories and return.
      if @empty
        make_directories
        return
      end

      if @dir.blank?
        raise "DIR must be set to continue. Execute `rake -D` for more information."
      end

      unless VALID_TYPES.include?(@type)
        raise "Unknown type: #{@type}. " << 
          "Please provide one: both, nucl or prot."
      end

      check_dependencies

      make_directories

      begin
        @dir.split(':').each do |d|
          unless File.directory?(d)    
            raise "Directory not found: #{d}"
          end

          @data = Dir.glob("#{d}/*.{tgz,tar.gz,tbz,tar.bz2}")

          if @data.blank?
            raise "Data not found. Please check your directory and try " <<
            "again.\nDirectory Entered: #{d}"
          end

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
                file_name = create_file_name(f, @blastdb_dir)
                extract_files(s, f, flag, File.join(@blastdb_dir, file_name, "peptides.fa"))
              elsif f.include?(@nucl_file)
                file_name = create_file_name(f, @blastdb_dir)
                extract_files(s, f, flag, File.join(@blastdb_dir, file_name, "contigs.fa"))
              elsif f.include?("gff")
                file_name = create_file_name(f, @gff_dir)
                extract_files(s, f, flag, File.join(@gff_dir, file_name, "annots.gff"))
              end
            end
          end
        end
        build_blast_db(@blastdb_dir)
      rescue Exception => e
        # Remove empty directories.
        `rm -rf #{@blastdb_dir}/*` if File.directory?(@blastdb_dir)
        `rm -rf #{@gff_dir}/*` if File.directory?(@gff_dir)
        raise e
      end
      readme
    end

  end
end
