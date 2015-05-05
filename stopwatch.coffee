colors       = require('colors/safe')
prettyHrtime = require('pretty-hrtime')


convertToMilliseconds = (timeTuple) ->
  Math.round(timeTuple[0] * 1000 + timeTuple[1] / 1000000)

addTuple = (a, b) ->
  [a[0] + b[0], a[1] + b[1]]

defaultColorFor = (milliseconds, timeTuple) ->
  switch
    when milliseconds <= 1 then 'gray'
    when milliseconds <= 25 then 'white'
    when milliseconds <= 100 then 'cyan'
    when milliseconds <= 1000 then 'blue'
    else 'yellow'

prettyAndColored = (timeTuple, options) ->
  if options?.factor
    console.log "timeTuple", timeTuple
    timeTuple = [timeTuple[0] * options.factor, timeTuple[1] * options.factor]
    console.log "timeTuple", timeTuple

  out = prettyHrtime timeTuple, options

  if options?.color?
    switch typeof options?.color
      when "function"
        color = options.color(convertToMilliseconds(timeTuple), timeTuple)
      when "string"
        color = options.color
      when "boolean"
        if options.color is true
          color = defaultColorFor(convertToMilliseconds(timeTuple), timeTuple)
      else
        throw new Error "Don't know how to handle options.color: #{options.color}"

    throw new Error "No such color: #{color}" unless colors[color]?
    out = colors[color](out)

  out



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
    throw new Error "Not started yet" unless @startTime?

    if @laps.length > 0
      lastTime = @laps[@laps.length - 1]
    else
      lastTime = @startTime

    @laps.push process.hrtime()
    @lapDeltas.push process.hrtime(lastTime)
    @

  lapSplit: ->
    if @laps.length > 0
      lastTime = @laps[@laps.length - 1]
    else
      lastTime = @startTime

    process.hrtime(lastTime)

  # Aliases
  @::startAnd = @::start
  @::stopAnd = @::stop
  @::stopAndClear = @::reset

  getLap: (index) ->
    if index < 0
      index = @lapDeltas.length + index

    @lapDeltas[index]

  getLapStartTuple: (index) ->
    if index < 0
      index = @laps.length + index

    @laps[index]

  prettyOut: (options) ->
    prettyAndColored @delta, options

  prettyOutLastLap: (options) ->
    @prettyOutLap -1, options

  prettyOutLap: (index, options) ->
    prettyAndColored @getLap(index), options

  prettyOutSplit: (options) ->
    prettyAndColored @split(), options

  milliseconds: ->
    convertToMilliseconds @delta

  seconds: ->
    @delta[0]

  nanoseconds: ->
    @delta[0] * 1000000000 + @delta[1]

  getLapAsMilliseconds: (index) ->
    convertToMilliseconds @getLap(index)

  numLaps: ->
    @laps.length

  lapsSum: ->
    @lapDeltas.reduce (sum, x) -> addTuple(sum, x)

  prettyOutLapsSum: ->
    prettyAndColored @lapsSum()

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
    prettyAndColored @lapsAverage()

  logLap: (message, options) ->
    console.log("  -> Lap:", @lap().prettyOutLastLap(options), '(' + @prettyOutSplit(options) + ')', message)

  logSplit: (message, options) ->
    console.log("  -> Split:", @prettyOutSplit(options), message)

  @withFakedDelta: (delta) ->
    s = new Stopwatch()
    s.delta = delta
    s



module.exports = Stopwatch



