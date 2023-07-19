# tanda_cli
<img width="454" alt="image" src="https://user-images.githubusercontent.com/13454550/231261971-a5fb9c80-2710-44e5-b6f4-b65673caa264.png">

## Installation

You will need Crystal 1.9.2 installed. I recommend using [`asdf`](https://github.com/asdf-vm/asdf) with the [crystal plugin](https://github.com/asdf-community/asdf-crystal).
```sh
asdf install crystal 1.9.2
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

# View your personal details
tanda_cli personal_details

# View or set the current user/organisation
tanda_cli current_user
tanda_cli current_user --set "Dan's Donuts"
# shows "current users" saved in config file
# if you want a fresh version use `tanda_cli refetch_users` to refetch from API or `tanda_cli me` to view from API
tanda_cli current_user --list

# refetch and save users/organisations to config
tanda_cli refetch_users

# View or set the current time zone
tanda_cli time_zone
tanda_cli time_zone --set "Australia/Brisbane"

# Check time worked today
tanda_cli time_worked today
tanda_cli time_worked today --display
tanda_cli time_worked today --offset -3 # shows time worked 3 days ago

# Check time worked this week
tanda_cli time_worked week
tanda_cli time_worked week --display
tanda_cli time_worked week --offset -1 # shows time worked last week

# Configure start of week
# See currently set start day
tanda_cli start_of_week display
# Set start of week
tanda_cli start_of_week --set sunday

# Clock in or clock out (including breaks)
tanda_cli clockin start
tanda_cli clockin finish
tanda_cli clockin break start
tanda_cli clockin break finish
# Skip clock in validations
tanda_cli clockin start --skip-validations
# Specify a clock in photo (JPG or PNG <= 1MB)
tanda_cli clockin start --photo "/path/to/photo.png"

# View current clock in status
tanda_cli clockin status
# Display clock ins for today
tanda_cli clockin display

# Configure clockin photo to be used on each clockin if not specified
# View configured photo or directory of photos
tanda_cli clockin photo view
# Set configured photo or directory (if set to a directory, a valid photo from that directory is randomly picked)
tanda_cli clockin photo --set "/path/to/photo.png"
# or
tanda_cli clockin photo --set "/path/to/dir/with/photos/"
# Clear configuration photo or directory
tanda_cli clockin photo clear

# Display leave balance information
tanda_cli balance

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
