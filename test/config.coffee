should = require 'should'
sinon = require 'sinon'
config = require '../src/config'

describe 'Configuration', ->

  describe 'read configuration file', ->

    it 'should throw an error if configFile does not exist', ->
      ( ->
        config.read 'this/file/does/not/exist.yml'
      ).should.throw()

  describe 'validate configuration', ->

    minimalConfig = {}

    beforeEach ->
      minimalConfig =
        prodFolder: 'anywhere'
        devFolder: 'anywhere'
        prodBaseUrl: '/anywhere'
        devBaseUrl: '/anywhere'
        views: ['**/*.html']
        assets:
          "style.css":
            files: ['style.css']

    it 'should throw an error if config.devFolder is missing', ->
      ( ->
        delete minimalConfig.devFolder
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.prodFolder is missing', ->
      ( ->
        delete minimalConfig.prodFolder
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.devBaseUrl is missing', ->
      ( ->
        delete minimalConfig.devBaseUrl
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.prodBaseUrl is missing', ->
      ( ->
        delete minimalConfig.prodBaseUrl
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.views is missing', ->
      ( ->
        delete minimalConfig.views
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.views is not an array', ->
      ( ->
        minimalConfig.views = {}
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.views is empty', ->
      ( ->
        minimalConfig.views = []
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if some config.views are not supported', ->
      ( ->
        minimalConfig.views = ['**/*.html', '**/*.unsupported_format']
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.assets is missing', ->
      ( ->
        delete minimalConfig.assets
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if config.assets is not an object', ->
      ( ->
        minimalConfig.assets = 'lol'
        config.validate minimalConfig
      ).should.throw()

    it 'should throw an error if somme config.assets are malformed', ->
      ( ->
        minimalConfig.assets =
          "style.css":
            file: ['style.css']
        config.validate minimalConfig
      ).should.throw()

