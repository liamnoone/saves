require 'yaml'
module Saves
  class Config
    class << self
      def games_list
        return @games_list if @games_list

        games_list  = config_file('games.yml')
        @games_list = YAML.load_file(games_list)
      end

      private

      def config_dir
        root_path = File.expand_path(File.join(__FILE__, '..', '..', '..'))
        File.join(root_path, 'config')
      end

      def config_file(config_file)
        File.expand_path File.join(config_dir, config_file)
      end
    end
  end
end
