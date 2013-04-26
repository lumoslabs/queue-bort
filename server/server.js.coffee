Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  if DeployTarget.all().count() == 0
    console.log "No servers found, generating from seed data"
    DeployTarget.create deployTargetName: 'lumos_rails', env: 'Production'
    DeployTarget.create deployTargetName: 'lumos_rails', env: 'Staging'
