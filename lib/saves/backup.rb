require 'zlib'
require 'tempfile'
require 'archive/tar/minitar'

module Saves
  class Backup
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def execute
      # We can't backup anything if no files exist
      return false unless source_exists?

      # Create the directory that we'll place backups in
      create_backup_destination

      # Copy the data into a temporary backup directory ...
      temp_directory = copy_to_temp_directory(@game.source)

      # ... Then compress the files in the destination specified in the configuration
      compress_files(temp_directory, @game.destination)

      true
    end

    def filename
      return unless @game
      prefix = @game.filename
      # YYMMDD_HHMMSS
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      "#{prefix}_#{timestamp}"
    end

    def extension
      "tar.gz"
    end

    def source_exists?
      return false unless @game
      File.exist? @game.source
    end

    def backup_destination_exists?
      return false unless @game
      File.exist? @game.destination
    end

    private

    # private: Create the directory the backup will eventually reside in
    def create_backup_destination
      return unless @game
      # Don't attempt to create the 
      return if backup_destination_exists?

      FileUtils.mkdir_p(@game.destination)
    end

    # public: Copy the files into a temporary directory
    # An intermediate directory is used to increase the atomicity of the compression
    def copy_to_temp_directory(source_directory)
      temp_directory = Dir.mktmpdir('saves')
      FileUtils.cp_r(source_directory, temp_directory)

      temp_directory
    end

    # Compress the 
    def compress_files(directory_to_compress, destination, cleanup_temp_files = true)
      backup_directory = @game.destination

      backup_file = File.join(backup_directory, filename)
      # If an extension is provided, append it to the filename
      backup_file = "#{backup_file}.#{extension}" if extension

      # Write to the backup file with GZip compression
      backup_writer = Zlib::GzipWriter.new(File.open(backup_file, 'wb'))
      Archive::Tar::Minitar.pack(directory_to_compress, backup_writer)

      FileUtils.rm_r(directory_to_compress) if cleanup_temp_files
    end
  end
end
