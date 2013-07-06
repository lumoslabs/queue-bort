Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user

Meteor.startup ->
  if DeployTarget.all().count() == 0
    console.log "No servers found, generating from seed data"
    DeployTarget.create deployTargetName: 'lumos_rails', env: 'Production', polling_server: 'app-worker3'
    DeployTarget.create deployTargetName: 'lumos_rails', env: 'Staging',    polling_server: 'staging'

Meteor.methods
  claimDeployTarget: (attrs) ->
    #TODO some form of security
    dt   = DeployTarget.findOne(_id: attrs.id)
    user = attrs.user
    dt.update cur_user: user
    Campfire.speak "#{dt.name()}/#{dt.attrs.env} claimed by #{user}"

  unclaimDeployTarget: (id) ->
    dt   = DeployTarget.findOne(_id: id)
    user = dt.attrs.cur_user
    dt.update cur_user: ''
    Campfire.speak "#{dt.name()}/#{dt.attrs.env} released by #{user}"
