module Quorum
  module Db

    #
    # Check dependencies.
    #
    def check_dependencies(dep)
      dep.each do |d|
        system("which #{d} > /dev/null 2>&1")
        if $?.exitstatus > 0
          raise "Dependency not found. Please add `#{d}` to your PATH."
        end
      end
    end

    #
    # Remove directory if rebuild is true.
    #
    def remove_directory(dir, rebuild)
      FileUtils.rm_rf(dir) if rebuild
    end

    #
    # Make directory.
    #
    def make_directory(dir)
      Dir.mkdir(dir) unless File.directory?(dir)
    end

    #
    # Make Quorum directories.
    #
    def make_directories
      begin
        if @gmapdb_dir
          remove_directory(@gmapdb_dir, @rebuild_db)
          make_directory(@gmapdb_dir)
        end

        if @blastdb_dir
          remove_directory(@blastdb_dir, @rebuild_db)
          make_directory(@blastdb_dir)
        end

        if @gff_dir
          remove_directory(@gff_dir, @rebuild_db)
          make_directory(@gff_dir)
        end

        if @log_dir
          make_directory(@log_dir)
        end
      rescue SystemCallError => e
        @output.puts e.message
        raise "Unable to make directory. " <<
        "Perhaps you forgot to execute the quorum initializer. \n\n" <<
        "rails generate quorum:install"
      end
    end

    class Gmap

      include Quorum::Db

      # Gmap dependencies
      DEPENDENCIES = ["gmap_build"]

      def initialize(args, output = $stdout)
        @dir         = args[:dir]
        @rebuild_db  = args[:rebuild_db]
        @empty       = args[:empty]
        @gmapdb_dir  = args[:gmapdb_dir]
        @log_dir     = args[:log_dir]

        @output = output
      end

      #
      # Display GMAP_README
      #
      def show_readme
        puts IO.read(File.join(File.dirname(__FILE__), "GMAP_README"))
      end

      def execute_gmap_build
        genome_name = File.basename(@data[0]).sub(/\.*(?<=\.)(fa\.gz|fa)$/, '')
        @output.puts "Executing gmap_build for #{genome_name}..."

        gmap_build_log = File.join(@log_dir, "gmap_build.log")

        cmd = "gmap_build " <<
        "-D #{@gmapdb_dir} " <<
        "-d #{genome_name} " <<
        "-T #{@gmapdb_dir} "

        cmd << "-g " if @data.join('').match('.gz')

        cmd << "#{@data.join(' ')} >> #{gmap_build_log} 2>&1"
        system(cmd)
        if $?.exitstatus > 0
          raise "gmap_build error. " <<
          "See #{gmap_build_log} for details."
        end
      end

      def build_gmap_db_data
        # Create necessary directories and return.
        if @empty
          make_directories
          return
        end

        if @dir.blank?
          raise "DIR must be set to continue. Execute `rake -D` for more information."
        end

        check_dependencies(DEPENDENCIES)
        make_directories

        begin
          @dir.split(':').each do |d|
            unless File.directory?(d)
              raise "Directory not found: #{d}"
            end

            @data = Dir.glob("#{d}/*.{fa,fa.gz}")

            if @data.blank?
              raise "Data not found. Please check your directory and try " <<
              "again.\nDirectory Entered: #{d}"
            end

            execute_gmap_build
          end
        rescue Exception => e
          # Remove empty directories.
          remove_directory(Dir.glob("#{@gmapdb_dir}/*"), true)
          raise e
        end
        show_readme
      end

    end

    #
    # Build Blast Database(s)
    #
    class Blast

      include Quorum::Db

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
      def show_readme
        puts IO.read(File.join(File.dirname(__FILE__), "BLAST_README"))
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

        check_dependencies(DEPENDENCIES)
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
          remove_directory(Dir.glob("#{@blastdb_dir}/*"), true)
          remove_directory(Dir.glob("#{@gff_dir}/*"), true)
          raise e
        end
        show_readme
      end

    end

  end
end
