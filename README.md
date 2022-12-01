# tanda_cli

## Disclaimer
This is a work in progress and (currently) primarily built to suit my own needs.

This repo is severely lacking tests at the moment so I'll probably be a bit relucant to accept pull requests as it will be difficult to write your own without a solid base.

Regardless of this, if you find this useful and have feature requests / ideas feel free to submit a pull request / issue.

## Installation

You will need Crystal 1.6.2 installed. I recommend using [`asdf`](https://github.com/asdf-vm/asdf) with the [crystal plugin](https://github.com/asdf-community/asdf-crystal).
```sh
asdf install crystal 1.6.2
```
Or you can checkout [this link](https://crystal-lang.org/install/) for platform specific instructions

Then
1. Clone the repository
2. Run `shards install`
3. Run `./scripts/build_prod.sh`
4. You now have a release build! This can be run with `./bin/tanda_cli` assuming you're in the root directory of this repository

This project doesn't currently distribute to any package managers or release any binaries.
I recommend aliasing if you intend on using it outside of the repo directory
```sh
alias tanda_cli="/link/to/tanda_cli/bin/tanda_cli"
```

## Usage
Upon running any command for the first time, you will be taken through an authentication flow where you will need to enter your username and password.
The retrieved token is stored in `~/.tanda_cli/config.json` (format / structure is subject to change at the moment)

#### Examples
```sh
# View information about the currently authenticated user (including organisations)
tanda_cli me

# View or set the current user/organisation
tanda_cli current_user
tanda_cli current_user --set "Dan's Donuts"
# shows "current users" saved in config file - if you want a fresh version use `tanda_cli me`
tanda_cli current_user --list

# View or set the current time zone
tanda_cli time_zone
tanda_cli time_zone --set "Australia/Brisbane"

# Check time worked today
tanda_cli time_worked today
tanda_cli time_worked today --display

# Check time worked this week
tanda_cli time_worked week
tanda_cli time_worked week --display

# Clock in or clock out (including breaks)
tanda_cli clockin start
tanda_cli clockin finish
tanda_cli clockin break start
tanda_cli clockin break finish
# View current clock in status
tanda_cli clockin status
# Display clock ins for today
tanda_cli clockin display

# Set "mode" (production | staging)
tanda_cli mode production # default
tanda_cli mode staging

# Refetch token for the current environment
# This will take you through the auth flow allowing a different region to be selected as well
tanda_cli refetch_token
```

## Development

### API Docs
https://my.tanda.co/api/v2

### Running your changes
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
