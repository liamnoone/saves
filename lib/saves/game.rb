require 'ostruct'

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

    def parse
      @game = data.game
      @source = parse_path(data.source)
      @destination = parse_path(data.destination)
      @filename = data.filename

      self
    end

    # Determine the filename for this game
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
