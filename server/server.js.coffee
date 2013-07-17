Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  unless QBConfig?
    console.log "!!! Missing QBConfig."
    console.log "Please add config file server/config.js.coffee (see server/config.js.coffee.example).\n"
  Campfire.init QBConfig.campfire
