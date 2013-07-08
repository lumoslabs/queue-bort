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

Meteor.methods
  claimDeployTarget: (attrs) ->
    #TODO some form of security
    dt   = DeployTarget.findOne(_id: attrs.id)
    user = attrs.user
    dt.update cur_user: user
    Campfire.speak "#{dt.name()} claimed by #{user}"

  unclaimDeployTarget: (id) ->
    dt   = DeployTarget.findOne(_id: id)
    user = dt.attrs.cur_user
    dt.update cur_user: ''
    Campfire.speak "#{dt.name()} released by #{user}"
