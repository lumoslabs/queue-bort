Meteor.Router.add '/deploy_target/:target/:env.json', 'GET', (target, env) ->
  dt = DeployTarget.findOne deployTargetName: target, env: env
  return 404 unless dt?
  JSON.stringify dt

Meteor.Router.add '/deploy_target/:target/:env.json', 'PATCH', (target, env) ->
  dt = DeployTarget.findOne deployTargetName: target, env: env
  return 404 unless dt?

  dt.update @request.body

  JSON.stringify dt
