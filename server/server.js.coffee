Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  if DeployTarget.all().count() == 0
    console.log "No servers found, generating from seed data"
    DeployTarget.create app: 'lumos_rails', env: 'production', server: 'production'
    DeployTarget.create app: 'lumos_rails', env: 'staging',    server: 'staging'
    for i in [1..8]
      DeployTarget.create app: 'lumos_rails', env: 'staging', server: "staging-#{i}"

  Campfire.init QBConfig.campfire
