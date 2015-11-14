Basic utility for backing up video game saves

Configuration is as follows, as a YAML file.
Supports basic maros, e.g. USER and HOME, to refer to the current user or their HOME directory
Macro format is "{MACRO}", e.g. "{HOME}/.local/share/Terraria" to refer to .local/share/Terraria, relative to the user's home directory
````yaml
----
- game: "Terraria"
  saves_location: "{HOME}/.local/share/Terraria"
  backup_location: "{HOME}/Games/Saves/Terraria"

- game: "Binding of Isaac: Rebirth"
  saves_location: "{HOME}/.local/share/binding of isaac rebirth"
  backup_location: "{HOME}/Games/Saves/boi_rebirth"
  filename: "boi_rebirth"
````

Those will backup files from the two provided locations.
"filename" key is optional. Without it, the file is generated using the game, lower-cased and witout non-alphanumeric characters.
Multi-directory backups are not supported
