require 'zlib'
require 'fileutils'
require 'archive/tar/minitar'

module Saves
  class Restore
    attr_reader :game, :filename_to_restore, :backup

    def initialize(game, filename_to_restore)
      @game = game
      @filename_to_restore = filename_to_restore
    end

    def execute
      # Can't restore a non-existent file
      return false unless backup_file_exists?

      # Ensure the directory we're restoring to exists
      create_restore_destination

      # Restore the files into the game's original source location
      restore_file(full_backup_path, @game.source)

      true
    end

    private

    def full_backup_path
      backup_directory = @game.destination
      File.join(backup_directory, @filename_to_restore)
    end

    def backup_file_exists?
      File.exist? full_backup_path
    end

    def restore_destination
      @game.source
    end

    def create_restore_destination
      return [] if restore_destination_exists?
      FileUtils.mkdir_p(restore_destination)
    end

    def restore_destination_exists?
      Dir.exist? restore_destination
    end

    def restore_file(file, destination)
      return false unless File.readable?(file) && Dir.exist?(destination)
      restore_device = Zlib::GzipReader.new(File.open(file, 'rb'))
      Archive::Tar::Minitar.unpack(restore_device, destination)
    end
  end
end
