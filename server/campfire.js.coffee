@Campfire =
  config: {}

  init: (attrs) ->
    _.extend @config, attrs
    @config.url    = "https://#{@config.domain}.campfirenow.com/room/#{@config.room}"

  http: (method, url, attrs) ->
    return false unless @config.enabled
    Meteor.http.call method, "#{@config.url}#{url}.json",
      auth: "#{@config.token}:X",
      data: attrs
    true

  speak: (msg) ->
    if @http('post', '/speak', message: body: msg)
      console.log "Campfire (#{new Date}): #{msg}"

  updateTopic: (topic) ->
    @http 'put', '', room: topic: topic

Meteor.methods
  speakToCampfire:     (msg)   -> Campfire.speak       msg
  updateCampfireTopic: (topic) -> Campfire.updateTopic topic
