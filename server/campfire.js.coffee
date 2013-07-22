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
    fullMsg = "#{@config.emoji} #{msg} [#{Meteor.absoluteUrl()}]"
    logMsg = "Campfire #{if @config.enabled then '' else '[disabled] '}"
    logMsg += "(#{new Date}): #{msg}"
    console.log logMsg
    @http('post', '/speak', message: body: fullMsg)

  updateTopic: (topic) ->
    @http 'put', '', room: topic: topic

Meteor.methods
  speakToCampfire:     (msg)   -> Campfire.speak       msg
  updateCampfireTopic: (topic) -> Campfire.updateTopic topic
