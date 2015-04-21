prettyHrtime = require('pretty-hrtime')


convertToMilliseconds = (timeTuple) ->
  Math.round(timeTuple[0] * 1000 + timeTuple[1] / 1000000)

addTuple = (a, b) ->
  [a[0] + x[0], a[1] + x[1]]


class Stopwatch
  constructor: ->
    # Work without new
    return new Stopwatch if not (this instanceof Stopwatch)

    @reset()

  reset: ->
    @laps = []
    @lapDeltas = []
    @stopped = true
    @

  start: ->
    @startTime = process.hrtime()
    @stopped = false
    @

  ensureStarted: ->
    @start() if @stopped is true

  stop: ->
    @delta = process.hrtime(@startTime)
    @stopped = true
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
  @::stopAndClear = @::reset

  prettyOut: (options) ->
    prettyHrtime @delta, options

  prettyOutLastLap: (options) ->
    prettyHrtime @lapDeltas[@lapDeltas.length - 1], options

  prettyOutSplit: (options) ->
    prettyHrtime @split(), options

  milliseconds: ->
    convertToMilliseconds @delta

  seconds: ->
    @delta[0]

  nanoseconds: ->
    @delta[0] * 1000000000 + @delta[1]

  numLaps: ->
    @laps.length

  lapsSum: ->
    @lapDeltas.reduce (sum, x) -> [sum[0] + x[0], sum[1] + x[1]]

  prettyOutLapsSum: ->
    prettyHrtime @lapsSum()

  _lapsSecondsSum: ->
    @lapDeltas.reduce (sum, x) ->
      sum + x[0]
    , 0

  _lapsNanosecondsSum: ->
    @lapDeltas.reduce (sum, x) ->
      sum + x[1]
    , 0

  lapsAverage: ->
    [@_lapsSecondsSum() / @numLaps(), @_lapsNanosecondsSum() / @numLaps()]

  prettyOutLapsAverage: ->
    prettyHrtime @lapsAverage()


module.exports = Stopwatch



