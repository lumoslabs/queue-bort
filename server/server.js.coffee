Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  if DeployTarget.all().count() == 0
    console.log "No servers found, generating from seed data"
    DeployTarget.create deployTargetName: 'lumos_rails', tag: 'Production'
    DeployTarget.create deployTargetName: 'lumos_rails', tag: 'Staging'

Meteor.Router.add '/deploy_target/:target/:tag.json', 'GET', (target, tag) ->
  dt = DeployTarget.findOne deployTargetName: target, tag: tag
  JSON.stringify dt
