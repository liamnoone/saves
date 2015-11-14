require 'zlib'
require 'tempfile'
require 'pathname'
require 'archive/tar/minitar'

module Saves
  class Backup
    attr_reader :game, :backup_file

    def initialize(game)
      @game = game
    end

    # public: Perform the backup.
    # Returns true for success, false when the backup didnt perform.
    def execute
      # We can't backup anything if no files exist
      return false unless saves_location_exists?

      # Create the directory that we'll place backups in
      create_backup_location

      # Copy the data into a temporary backup directory ...
      temp_directory = copy_to_temp_directory(@game.saves_location)

      # ... Then compress the files in the backup location specified in the configuration
      compress_files(temp_directory, @game.backup_location)

      true
    end

    # public: Determine the base filename of the backup
    # This can be provided in the yaml file. If there, it'll be used
    # Otherwise, the filename will be generated from the game name
    def filename
      return unless @game
      prefix = @game.filename
      # YYMMDD_HHMMSS
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      "#{prefix}_#{timestamp}"
    end

    # public: The extension to append to the filename
    # This may be null
    def extension
      "tar.gz"
    end

    # public: Does the initial location of the saves exist?
    def saves_location_exists?
      return false unless @game
      File.exist? @game.saves_location
    end

    # public: Does the directory the saves will be saved exist?
    def backup_location_exists?
      return false unless @game
      File.exist? @game.backup_location
    end

    private

    # private: Create the directory the backup will eventually reside in
    def create_backup_location
      return unless @game
      # Don't attempt to create the 
      return if backup_location_exists?

      FileUtils.mkdir_p(@game.backup_location)
    end

    # private: Copy the files into a temporary directory
    # An intermediate directory is used to increase the atomicity of the compression
    def copy_to_temp_directory(source_directory)
      temp_directory = Dir.mktmpdir('saves')
      FileUtils.cp_r("#{source_directory}/.", temp_directory)
      temp_directory
    end

    # private: Compress all files in a directory into a single archive.
    # If cleanup_temp_files is true, the files in the temporary directory are removed
    def compress_files(directory_to_compress, destination, cleanup_temp_files = true)
      backup_directory = @game.backup_location

      @backup_file = File.join(backup_directory, filename)
      # If an extension is provided, append it to the filename
      @backup_file = "#{backup_file}.#{extension}" if extension

      # Change into the directory, so that the tar archive will have relative paths
      FileUtils.cd(directory_to_compress) do
        # Write to the backup file with GZip compression
        backup_writer = Zlib::GzipWriter.new(File.open(backup_file, 'wb'))
        Archive::Tar::Minitar.pack('.', backup_writer)
      end

      FileUtils.rm_r(directory_to_compress) if cleanup_temp_files
    end
  end
end
