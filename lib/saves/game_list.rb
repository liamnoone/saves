module Saves
  class GameList
    include Enumerable

    attr_reader :games
    attr_reader :games_data

    def initialize(games_data = [])
      @games_data = games_data
    end

    def to_s
      game_names.join(', ')
    end

    def inspect
      names = game_names.map { |game_name| %{"#{game_name}"} }
      "GameList(#{names.join(', ')})"
    end

    def games
      @games ||= @games_data.map do |game_data|
        Game.new(game_data).parse
      end
    end

    alias :parse :games

    def game_names
      games.map { |game| game.name }
    end

    def self.empty
      new
    end
  end
end
