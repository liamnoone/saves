require 'thor'
module Saves
  class CLI < Thor
    desc "list", "List all games being backed up"
    def list
      say("List of Games:", :bold)
      GameList.from_config.each do |game|
        puts game.name
      end
    end

    desc "backup", "Create a new backup"
    def backup(game_name = nil)
      game_name ? backup_game(game_name) : backup_all
    end

    no_commands do
      def couldnt_find_game!(game_name)
        say "Couldn't find the game '", nil, false
        say game_name, :bold, false
        say "'. Quitting"
        abort
      end

      def run_backup!(game)
        backup = Backup.new(game)
        say "Running backup for #{game.name}..."
        begin
          backup.execute
        rescue => exception
          say "An error occurred when running the backup"
          say exception.message

          if ENV['VERBOSE']
            say exception.backtrace
          end
        end

        say "Successfully created new backup for "
        say game.name, :bold
      end

      # Run a backup for a single game
      def backup_game(game_name)
        games = GameList.from_config
        game = games.find_game(game_name)

        couldnt_find_game!(game_name) unless game
        run_backup!(game)
      end

      def backup_all
        games = GameList.from_config
        games.each { |game| run_backup!(game) }
      end

      def list_backups_for_game(game)
        say "Backups for the game "
        say "#{game.name}:", :bold

        backups_for_game = game.backups
        backups_for_game.each do |backup|
          say "File: "; say(backup, :bold)
          backup_stats = game.stats_of_backup(backup)
          say "Created: "; say(backup_stats.atime, :bold, true)
        end
        say  # Empty line
      end
    end

    desc "backups", "List all the backups"
    def backups
      GameList.from_config.each do |game|
        list_backups_for_game(game)
      end
    end
  end
end
