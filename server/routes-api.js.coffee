Meteor.Router.add '/deploy_target/:app/:server.json', 'GET', (app, server) ->
  dt = DeployTarget.findOne app: app, server: server
  return 404 unless dt?
  JSON.stringify dt

Meteor.Router.add '/deploy_target/:app/:server.json', 'PATCH', (app, server) ->
  dt = DeployTarget.findOne app: app, server: server
  return 404 unless dt?

  dt.update @request.body

  JSON.stringify dt

Meteor.Router.add '/deploy_to/:app/:server.json', 'POST', (app, server) ->
  dt = DeployTarget.findOne app: app, server: server
  return 404 unless dt?

  commit = @request.body.commit
  ref    = @request.body.ref
  return 400 unless commit?.sha?

  dt.deployed ref: ref, commit: commit

  JSON.stringify dt
