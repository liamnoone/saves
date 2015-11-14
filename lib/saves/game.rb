require 'ostruct'
require 'pathname'

module Saves
  class Game
    attr_reader :data, :game, :source, :destination
    alias :name :game

    def initialize(data)
      @data = OpenStruct.new(data)
    end

    def to_s
      self.name
    end

    def inspect
      %{Game("#{self.name}")}
    end

    def <=>(other_game)
      name <=> other_game.name
    end

    def parse
      @game = data.game
      @source = parse_path(data.source)
      @destination = parse_path(data.destination)
      @filename = data.filename

      self
    end

    # public: Get a list of all available backups saved in the {@destination} directory
    #
    # Returns an empty list if the backups directory doesn't exist
    # Returns a list of empty files in the backup directory
    # By default, this is without leading paths
    #
    # NOTE: Does not support subdirectories
    def backups(use_full_path = false)
      return [] unless Dir.exist?(@destination)
      # Get the files in the directory, without the directory name
      Pathname.new(@destination).children(use_full_path).map(&:to_path)
    end

    def stats_of_backup(backup_filename)
      File.stat(File.join(@destination, backup_filename))
    end

    # public: Determine the filename for this game
    # If one is provided in the config file, use that value
    # Otherwise, format the game name to lowercase and remove non-alphanumerics
    # "The Binding Of Isaac: Rebirth" => "the_binding_of_isaac_rebirth"
    def filename
      return @filename if @filename
      name.downcase.gsub(/\W/, '_').squeeze('_')
    end

    # Parse the path in the string and replace any {VALUES}
    # example:
    #   parse_path "{HOME}/destination", { '{HOME}' => '/home/user' }
    #   # => "/home/user/destination"
    def parse_path(path, substitutions = default_substitutions)
      path.gsub(/{.*?}/, substitutions)
    end

    def default_substitutions
      {
        '{GAME}' => self.game,
        '{SOURCE}' => self.source,
        '{DESTINATION}' => self.destination,

        '{HOME}' => ENV.fetch('HOME'),
        '{USER}' => ENV.fetch('USER')
      }
    end
  end
end
