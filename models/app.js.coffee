class @App extends MongoModel
  @collection: new Meteor.Collection "apps"

  repoLink: -> "#{@attrs.repo_link}/commits"
