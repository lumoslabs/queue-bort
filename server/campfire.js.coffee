@Campfire =
  config:
    token:  process.env.CAMPFIRE_TOKEN
    domain: process.env.CAMPFIRE_DOMAIN
    room:   process.env.CAMPFIRE_ROOM

  http: (method, url, attrs) ->
    Meteor.http.call method, "#{@config.url}#{url}.json",
      auth: "#{@config.token}:X",
      data: attrs

  speak: (msg) ->
    console.log "Campfire (#{new Date}): #{msg}"
    @http 'post', '/speak', message: body: msg

  updateTopic: (topic) ->
    @http 'put', '', room: topic: topic

Campfire.config.url = "https://#{Campfire.config.domain}.campfirenow.com/room/#{Campfire.config.room}"

Meteor.methods
  speakToCampfire:     (msg)   -> Campfire.speak       msg
  updateCampfireTopic: (topic) -> Campfire.updateTopic topic
