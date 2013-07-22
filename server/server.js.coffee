Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  unless QBConfig?
    console.log "!!! Missing QBConfig."
    console.log "Please add config file server/config.js.coffee (see server/config.js.coffee.example).\n"
  Campfire.init QBConfig.campfire

  @checkTimeout = ->
    DeployTarget.each (dt) ->
      if oustedOwner = dt.checkTimeout()
        newOwner = dt.owner()
        newOwnerText = if newOwner? then "reserved for #{newOwner}" else "free"
        msg = "#{dt.name()} reservation time ran out. Ousted #{oustedOwner}; now #{newOwnerText}"
        Campfire.speak msg
  @checkTimeout()
  Meteor.setInterval @checkTimeout, 1000 * 60 * QBConfig.reservationTime.minutesBetweenChecks
