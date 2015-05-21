assert = require('assert')
should = require('should')

Stopwatch = require('../stopwatch')

describe 'stopwatch', ->

  describe 'creation', ->
    it 'can be instantiated', ->
      s = new Stopwatch
      s.should.be.an.instanceof(Stopwatch)

    it 'can be instantiated without new', ->
      s = Stopwatch()
      s.should.be.an.instanceof(Stopwatch)

    it 'is initialized empty', ->
      s = Stopwatch()
      s.stopped.should.be.true
      s.numLaps().should.be.eql(0)

  describe 'basic functionality', ->

    it 'can be started', ->
      s = Stopwatch()
      s.start()
      s.stopped.should.be.false

    it 'can be started in chain', ->
      s = Stopwatch().start()
      s.stopped.should.be.false

    it 'start can chain', ->
      s = Stopwatch().start()
      s.start().should.be.exactly(s)
      s.startAnd().should.be.exactly(s)

    it 'has a startAnd alias', ->
      s = Stopwatch().startAnd()
      s.stopped.should.be.false

    it 'can ensure started', ->
      s = Stopwatch().ensureStarted()
      s.stopped.should.be.false

    it 'can ensure started, but not restart', ->
      s = Stopwatch().start()
      origStartTime = s.startTime
      s.ensureStarted()
      s.startTime.should.eql(origStartTime)

    it 'can be stopped and track duration', ->
      s = Stopwatch().start()
      s.stop()
      s.stopped.should.be.true
      s.nanoseconds().should.be.greaterThan(0)

    it 'stop can chain', ->
      s = Stopwatch().start()
      s.stop().should.be.exactly(s)
      s.stopAnd().should.be.exactly(s)

    it 'has a stopAnd alias', ->
      s = Stopwatch().start().stopAnd()
      s.stopped.should.be.true

    it 'can be cleared', (done) ->
      s = Stopwatch().start()

      setTimeout ->
        s.lap()
        s.reset()
        s.stopped.should.be.true
        s.numLaps().should.be.eql(0)
        done()
      , 10


  describe 'numeric output', ->
    beforeEach (done) ->
      return done() if @s?

      @s = Stopwatch().start()

      setTimeout =>
        @s.stop()
        done()
      , 100

    it 'can output milliseconds', ->
      @s.milliseconds().should.be.approximately(100, 30)

    it 'can output seconds', ->
      @s.seconds().should.be.eql(0)

    it 'can output nanoseconds', ->
      @s.nanoseconds().should.be.approximately(100000000, 3000000)

  describe 'pretty output', ->
    beforeEach (done) ->
      return done() if @s?

      @s = Stopwatch().start()

      setTimeout =>
        @s.stop()
        done()
      , 100

    it 'can output prettily', ->
      @s.prettyOut().should.be.match /\d+ ms/

    it 'will output prettily with different units', ->
      Stopwatch.withFakedDelta([1,0]).prettyOut().should.be.eql('1 s')
      Stopwatch.withFakedDelta([1,1000000]).prettyOut().should.be.eql('1 s')
      Stopwatch.withFakedDelta([0,1000000]).prettyOut().should.be.eql('1 ms')
      Stopwatch.withFakedDelta([0,100000]).prettyOut().should.be.eql('100 μs')
      Stopwatch.withFakedDelta([0,100]).prettyOut().should.be.eql('100 ns')

    it 'takes various pretty-hrtime options', ->
      @s.prettyOut({ verbose: true }).should.be.match /\d+ milliseconds \d+ microseconds \d+ nanoseconds/
      @s.prettyOut({ precise: true }).should.be.match /\d+\.\d+ ms/

  describe 'splits', ->
    beforeEach ->
      @s = Stopwatch().start()

    it 'can take a split', ->
      @s.split()[1].should.be.greaterThan(0)

    it 'can pretty out a split', ->
      @s.prettyOutSplit().should.match /\d+ μs/


  describe 'laps', ->
    beforeEach ->
      @s = Stopwatch().start()

    it 'can lap', ->
      @s.lap()
      @s.numLaps().should.be.eql(1)

    it 'can\'t lap if not started', ->
      should.throws((-> Stopwatch().lap()), Error, "Not started yet")

    it 'can collect a list of laps', ->
      @s.lap()
      @s.lap()
      @s.lap()
      @s.numLaps().should.be.eql(3)

    it 'get a specific lap', ->
      @s.lap()
      @s.lap()
      @s.lap()

      for i in [0...3]
        tuple = @s.getLap(i)
        tuple[0].should.be.eql(0)
        tuple[1].should.be.greaterThan(0)

    it 'get a specific lap with negative index', ->
      @s.lap()
      @s.lap()
      @s.lap()

      for i in [-1...-4]
        positiveIndex = 3 + i
        @s.getLap(i).should.be.eql(@s.getLap(positiveIndex))

    it 'can pretty out the last lap', ->
      @s.lap().prettyOutLastLap().should.match /\d+ (μs|ns)/

    it 'can pretty out the a specific lap', ->
      @s.lap()
      @s.lap()
      @s.lap()

      for i in [0...3]
        tuple = @s.prettyOutLap(i).should.match /\d+ (μs|ns)/

    it 'has a helper to log a lap', ->
      oldConsoleLog = console.log
      called = false

      try
        console.log = (args...) =>
          called = true
          args.join(' ').should.match ///
            \s\s
            ->
            \s
            Lap:
            \s
            #{@s.prettyOutLastLap()}
            \s
            \(\d+\s[^\s]+\)
            \s
            some\smessage
          ///

        @s.logLap('some message')

        called.should.be.true

      finally
        console.log = oldConsoleLog

    it 'can override the lap start', ->
      @s.lap()
      @s.overrideLapStart()
      console.log "@s._lastLapStart()", @s._lastLapStart()
      console.log "@s.getLapStartTuple(-1)", @s.getLapStartTuple(-1)
      @s._lastLapStart().should.not.equal(@s.getLapStartTuple(-1))



  describe 'stats', ->
    beforeEach ->
      @s = Stopwatch().start()
      @s.lap()
      @s.lap()
      @s.lap()

    it 'can sum laps', ->
      tuple = @s.lapsSum()
      tuple[0].should.be.eql(0)
      tuple[1].should.be.eql (@s.getLap(i)[1] for i in [0...3]).reduce (sum, x) -> sum + x

    it 'can pretty output laps sum', ->
      @s.prettyOutLapsSum().should.match /\d+(\.\d)? μs/

    it 'can average laps', ->
      tuple = @s.lapsAverage()
      tuple[0].should.be.eql(0)
      tuple[1].should.be.eql (@s.getLap(i)[1] for i in [0...3]).reduce((sum, x) -> sum + x) / 3

    it 'can pretty output laps average', ->
      @s.prettyOutLapsAverage().should.match /\d+(\.\d)? μs/

