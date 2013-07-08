Meteor.Router.add '/deploy_target/:app/:server.json', 'GET', (target, env) ->
  dt = DeployTarget.findOne app: app, server: server
  return 404 unless dt?
  JSON.stringify dt

Meteor.Router.add '/deploy_target/:app/:server.json', 'PATCH', (target, env) ->
  dt = DeployTarget.findOne app: app, server: server
  return 404 unless dt?

  dt.update @request.body

  JSON.stringify dt
