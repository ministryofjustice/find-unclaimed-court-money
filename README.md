# README

An application that enables searches for unclaimed court money. Also allows admins to upload a CSV of the latest data.

## Development

### Working on the Code

Work should be based off of, and PRed to, the main branch. We use the GitHub
PR approval process so once your PR is ready you'll need to have one person
approve it, and the CI tests passing, before it can be merged.


### Basic Setup

#### Cloning This Repository

Clone this repository then `cd` into the new directory

```
$ git clone git@github.com:ministryofjustice/find-unclaimed-court-money.git
$ cd find-unclaimed-court-money
```

### Installing the app for development

##### Latest Version of Ruby

If you don't have `rbenv` already installed, install it as follows:
```
brew install rbenv
rbenv init
```

Use `rbenv` to install the latest version of ruby as defined in `.ruby-version` (make sure you are in the repo path):

```
$ rbenv install
$ rbenv init
$ rbenv rehash
```
Follow the instructions printed out from the `rbenv init` command and update your `~/.bash_profile` or equivalent file accordingly, then start a new terminal and navigate to the repo directory.

#### Database Setup
The application uses postgresql
```
brew install postgresql
```

Use the setup command to install gems and create the database with seed data
```
bin/setup
```

#### Assets
Yarn and node are required to build css and js assets
```
brew install node
brew install yarn
```


#### Running locally
Use the dev command to run the application
```
bin/dev
```


