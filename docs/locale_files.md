# Locale files
Chop up your locale files and place them in subdirectories; organise them any
way you prefer. Currently, Rosetta supports YAML and JSON files and you can mix
formats together.

!!! warning
    Beware, though, that there is a fixed loading order. JSON files are loaded
    first, then YAML files. So in the unlikely situation where you have the same
    key in a JSON and a YAML file, YAML will take precedence.
