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

    def find_game(game_name)
      detect do |game|
        game.name == game_name
      end
    end

    def each
      games.each do |game|
        yield game
      end
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

    def self.from_config
      new(Config.games_list)
    end
  end
end
