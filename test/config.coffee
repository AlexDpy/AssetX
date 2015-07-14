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

    it 'should throw an error if config.devFolder is missing', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          views: ['**/*.html']
          assets:
            "style.css":
              files: ['style.css']
      ).should.throw()

    it 'should throw an error if config.prodFolder is missing', ->
      ( ->
        config.validate
          devFolder: 'anywhere'
          views: ['**/*.html']
          assets:
            "style.css":
              files: ['style.css']
      ).should.throw()

    it 'should throw an error if config.views is missing', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          assets:
            "style.css":
              files: ['style.css']
      ).should.throw()

    it 'should throw an error if config.views is not an array', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          views: {}
          assets:
            "style.css":
              files: ['style.css']
      ).should.throw()

    it 'should throw an error if config.views is empty', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          views: []
          assets:
            "style.css":
              files: ['style.css']
      ).should.throw()

    it 'should throw an error if some config.views are not supported', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          views: ['**/*.html', '**/*.unsupported_format']
          assets:
            "style.css":
              files: ['style.css']
      ).should.throw()

    it 'should throw an error if config.assets is missing', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          views: ['**/*.html']
      ).should.throw()

    it 'should throw an error if config.assets is not an object', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          views: ['**/*.html']
          assets: 'lol'
      ).should.throw()

    it 'should throw an error if somme config.assets are malformed', ->
      ( ->
        config.validate
          prodFolder: 'anywhere'
          devFolder: 'anywhere'
          views: ['**/*.html']
          assets:
            "style.css":
              file: ['style.css']
      ).should.throw()

