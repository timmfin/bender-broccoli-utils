prettyHrtime = require('pretty-hrtime')


class Stopwatch
  constructor: ->
    # Work without new
    return new Stopwatch if not (this instanceof Stopwatch)

  start: ->
    @startTime = process.hrtime()
    @

  stop: ->
    @delta = process.hrtime(@startTime)
    @

  # Aliases
  @::startAnd = @::start
  @::stopAnd = @::stop

  prettyOut: (options) ->
    prettyHrtime @delta, options

  milliseconds: ->
    Math.round(@delta[0] * 1000 + @delta[1] / 1000000)

  seconds: ->
    @delta[0]

  nanoseconds: ->
    @delta[0] * 1000000000 + @delta[1]


module.exports = Stopwatch



