assert = require('assert')
should = require('should')

{ extractExtension, convertFromPreprocessorExtension, DEFAULT_PREPROCESSOR_EXTENSIONS } = require('../extension-utils')

describe 'extension-utils', ->

  describe 'extractExtension', ->
    it 'should return an empty string for paths without an extension', ->
      extractExtension('a').should.be.eql ''
      extractExtension('a/b/c').should.be.eql ''

    it 'should return the extension', ->
      extractExtension('a.txt').should.be.eql 'txt'
      extractExtension('a/b/c.txt').should.be.eql 'txt'

    it 'should return only the "last" extension', ->
      extractExtension('a.other.txt').should.be.eql 'txt'
      extractExtension('a/b/c.other.txt').should.be.eql 'txt'

    it 'should only extract the onlyAllow-ed extensions', ->
      options =
        onlyAllow: ['js', 'css']

      extractExtension('a.txt', options).should.be.eql ''
      extractExtension('a.js', options).should.be.eql 'js'
      extractExtension('a.css', options).should.be.eql 'css'
      extractExtension('a.css.other', options).should.be.eql ''


  describe 'DEFAULT_PREPROCESSOR_EXTENSIONS', ->
    it 'should be an object with CSS and JS nested objects', ->
      DEFAULT_PREPROCESSOR_EXTENSIONS.should.be.an.Object

      DEFAULT_PREPROCESSOR_EXTENSIONS.should.have.property 'js'
      DEFAULT_PREPROCESSOR_EXTENSIONS.should.have.property 'css'

      DEFAULT_PREPROCESSOR_EXTENSIONS.js.should.be.an.Object
      DEFAULT_PREPROCESSOR_EXTENSIONS.css.should.be.an.Object


  describe 'convertFromPreprocessorExtension', ->
    conv = convertFromPreprocessorExtension

    it 'should convert basic/default preprocssor extensions', ->
      conv('a.coffee').should.be.eql 'a.js'
      conv('a.iced').should.be.eql 'a.js'
      conv('a.jsx').should.be.eql 'a.js'
      conv('a.ts').should.be.eql 'a.js'
      conv('a.dart').should.be.eql 'a.js'

      conv('a.sass').should.be.eql 'a.css'
      conv('a.scss').should.be.eql 'a.css'
      conv('a.less').should.be.eql 'a.css'
      conv('a.stylus').should.be.eql 'a.css'

    it 'should not modify other extensions', ->
      conv('a.other').should.be.eql 'a.other'
      conv('a.js').should.be.eql 'a.js'
      conv('a.css').should.be.eql 'a.css'

    it "should pass-through onlyAllow option", ->
      onlyAllow = ['coffee']

      conv('a.sass', { onlyAllow: onlyAllow }).should.be.eql 'a.sass'
      conv('a.coffee', { onlyAllow: onlyAllow }).should.be.eql 'a.js'

    it "should fallback to parentFilename if path doesn't have extension", ->
      onlyAllow = [
        'sass'
        'scss'
        'less'
        'stylus'
        'coffee'
        'iced'
        'jsx'
        'ts'
        'dart'
      ]

      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.coffee' }).should.be.eql 'a/b/c.other.js'

      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.coffee' }).should.be.eql 'a/b/c.other.js'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.iced' }).should.be.eql 'a/b/c.other.js'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.jsx' }).should.be.eql 'a/b/c.other.js'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.ts' }).should.be.eql 'a/b/c.other.js'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.dart' }).should.be.eql 'a/b/c.other.js'

      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.sass' }).should.be.eql 'a/b/c.other.css'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.scss' }).should.be.eql 'a/b/c.other.css'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.less' }).should.be.eql 'a/b/c.other.css'
      conv('a/b/c.other', { onlyAllow: onlyAllow, parentFilename: 'p.stylus' }).should.be.eql 'a/b/c.other.css'


  describe 'convertFromPreprocessorExtension.curry', ->
    # TODO

    curriedConv = convertFromPreprocessorExtension.curry
      preprocessorsByExtension:
        # Not working yet
        # html:
        #   'html.jade': true

        crazy:
          extracrazy: true

        css:
          sass: true
          scss: true

        js:
          coffee: true
          jsx: true
          lyaml: true

          jade: true
          handlebars: true


    it 'should look for extensions in curried preprocessor extension map', ->
      curriedConv('a.extracrazy').should.be.eql 'a.crazy'
      curriedConv('a.sass').should.be.eql 'a.css'

    it 'should not modify extensions that are not in the curried map', ->
      curriedConv('a.iced').should.be.eql 'a.iced'


    # This isn't working yet... (also not sure if it is quite needed yet)

    # it 'should modify preprocssor extensions with periods in them', ->
    #   curriedConv('a.html.jade').should.be.eql 'a.html'

