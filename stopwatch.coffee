prettyHrtime = require('pretty-hrtime')


class Stopwatch
  constructor: ->
    # Work without new
    return new Stopwatch if not (this instanceof Stopwatch)

    @laps = []
    @lapDeltas = []

  start: ->
    @startTime = process.hrtime()
    @

  stop: ->
    @delta = process.hrtime(@startTime)
    @

  split: ->
    process.hrtime(@startTime)

  lap: ->
    if @laps.length > 0
      lastTime = @laps[@laps.length - 1]
    else
      lastTime = @startTime

    @laps.push process.hrtime()
    @lapDeltas.push process.hrtime(lastTime)
    @

  # Aliases
  @::startAnd = @::start
  @::stopAnd = @::stop

  prettyOut: (options) ->
    prettyHrtime @delta, options

  prettyOutLastLap: (options) ->
    prettyHrtime @lapDeltas[@lapDeltas.length - 1], options

  prettyOutSplit: (options) ->
    prettyHrtime @split(), options

  milliseconds: ->
    Math.round(@delta[0] * 1000 + @delta[1] / 1000000)

  seconds: ->
    @delta[0]

  nanoseconds: ->
    @delta[0] * 1000000000 + @delta[1]


module.exports = Stopwatch



