Accounts.onCreateUser (options, user) ->
  user.profile ||= {}
  user.profile.name ||= user.services.github.username
  user
