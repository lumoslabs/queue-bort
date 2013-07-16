Meteor.startup ->
  if DeployTarget.all().count() == 0
    console.log "No servers found, generating from seed data"
    DeployTarget.create app: 'lumos_rails', env: 'production', server: 'production'
    DeployTarget.create app: 'lumos_rails', env: 'staging',    server: 'staging'
    for i in [1..8]
      DeployTarget.create app: 'lumos_rails', env: 'staging', server: "staging-#{i}"

  if App.all().count() == 0
    console.log "No apps registered, generating from seed data"
    App.create name: 'lumos_rails', repo_link: 'https://github.com/lumoslabs/lumos_rails'
