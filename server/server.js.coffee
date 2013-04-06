Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  if Server.all().count() == 0
    console.log "No servers found, generating from seed data"
    Server.create serverName: 'lumos_rails', tag: 'Production'
    Server.create serverName: 'lumos_rails', tag: 'Staging'
