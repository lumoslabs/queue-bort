class @App extends Module
  @extend  MongoModel.classProps
  @include MongoModel.instanceProps
  constructor: (@attrs) ->

  repoLink: -> "#{@attrs.repo_link}/commits"

  @collection: new Meteor.Collection "apps"
