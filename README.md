# tanda_cli
<img width="454" alt="image" src="https://github.com/user-attachments/assets/ede1ec52-c672-41fa-a521-27b71c106263">

## Installation

You will need Crystal 1.21.0 installed. I recommend using [`asdf`](https://github.com/asdf-vm/asdf) with the [crystal plugin](https://github.com/asdf-community/asdf-crystal).
```sh
asdf install crystal 1.21.0
```
Or you can checkout [this link](https://crystal-lang.org/install/) for platform specific instructions

Then
1. Clone the repository
2. Run `shards install`
3. Run `./scripts/build-prod.sh`
4. You now have a release build! This can be run with `./bin/tanda_cli` assuming you're in the root directory of this repository

This project doesn't currently distribute to any package managers or release any binaries.
I recommend aliasing if you intend on using it outside of the repo directory
```sh
alias tanda_cli="/link/to/tanda_cli/bin/tanda_cli"
```

## Usage
Upon running any command for the first time, you will be taken through an authentication flow where you will need to enter your username and password.
Your preferences are stored under `~/.config/tanda_cli/` and the retrieved token in `~/.local/share/tanda_cli/state.json` (format / structure is subject to change at the moment)

See `--help` for a list of commands (each subcommand also accepts a `--help` flag)
```fish
╰─❯ tanda_cli help
A CLI application for people using Tanda/Workforce.com

Usage: tanda_cli [options] <command>

Commands:
  auth              Manage authentication
  balance           Check your leave balances
  clockin           Clock in/out
  completions       Print a shell completion script
  config            Show where the configuration lives or what it contains
  current_user      View the current user, list available users or set the current user
  me                Get your own information
  mode              Set the mode to run commands in (production/staging/custom <url>)
  personal_details  Get your personal details
  regular_hours     View or set your regular hours
  start_of_week     Set the start of the week (e.g. monday/sunday)
  time_worked       See how many hours you've worked
  help              Show this help

Options:
      --no-colour  Disable ANSI colours
  -h, --help       Show this help
```

#### Examples
```sh
# Clock in
tanda_cli clockin start

# Set a default clockin photo to be used with clockins (can be a specific photo or directory of photos to be chosen at random)
tanda_cli clockin photo set /Users/me/Pictures/clockin_photos/my_cool_photo.png
tanda_cli clockin photo set /users/me/Pictures/clockin_photos # as a directory

# See time worked today or for the week
tanda_cli time_worked today
tanda_cli time_worked week --display # both options accept a flag to display the shifts

# Goes through each week of your roster to find your working hours (makes `time_worked` much more accurate)
tanda_cli regular_hours determine

# Displays your regular hours for the week
tanda_cli regular_hours display

# Set the mode to run commands in
tanda_cli mode production # this is the default mode
tanda_cli mode staging
```

## Shell completions

`tanda_cli` generates completion scripts for fish, bash, and zsh. Source it at shell startup so completions always match the installed binary:

```fish
# fish (~/.config/fish/config.fish)
tanda_cli completions fish | source
```
```sh
# bash (~/.bashrc)
eval "$(tanda_cli completions bash)"
```
```sh
# zsh (~/.zshrc, after compinit)
source <(tanda_cli completions zsh)
```

## Development

### API Docs
https://my.tanda.co/api/v2

### Running your changes
```sh
crystal run src/tanda_cli.cr -- <command/s>
```

#### Examples
```sh
# With debug logs enabled
crystal run src/tanda_cli.cr -- me

# Without debug logs
crystal run src/tanda_cli.cr --no-debug -- me
```

## Contributing

1. Clone repo
2. Implement your idea / fix bug
3. Make a pull request

## Contributors

- [Daniel Gilchrist](https://github.com/DanielGilchrist) - creator and maintainer
