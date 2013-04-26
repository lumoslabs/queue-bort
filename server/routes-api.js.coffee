Meteor.Router.add '/deploy_target/:target/:env.json', 'GET', (target, env) ->
  dt = DeployTarget.findOne deployTargetName: target, env: env
  JSON.stringify dt
