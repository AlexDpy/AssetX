fs = require 'fs'
glob = require 'glob'
path = require 'path'
gulp = require 'gulp'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
output = require './output'
config = require './config'
RegExpHelper = require './regexp-helper'

module.exports = class AssetX

  constructor: (@options) ->
    try
      @config = config.read @options.configFile
    catch e
      throw new Error 'The configFile "' + @options.configFile + '" does not exist'

    config.validate @config
    @config = config.mergeRecursive @config, @options

  replace: (reset = false) ->
    output.title 'Replace ...' if not reset

    for pattern in @config.views
      for viewFile in glob.sync pattern
        match = false
        data = fs.readFileSync viewFile, encoding: 'utf-8'

        for assetName, assetConfig of @config.assets
          for env in ['dev', 'prod']
            helper = new RegExpHelper(viewFile, env, assetName, assetConfig)
            regExp = helper.getRegExp()

            if data.match regExp
              match = true
              data = data.replace regExp, helper.getReplacement(reset)
              output.log 'Replace ' + env + ':' + assetName + ' tag in ' + viewFile if not reset

        fs.writeFileSync viewFile, data, encoding: 'utf-8' if match is true

  concat: ->
    output.title 'Concat ...'

    for assetName, assetConfig of @config.assets
      output.log 'Concat ' + assetName

      ext = path.extname(assetName).substr 1
      specialPipe = if ext is 'css' then minifyCss else uglify

      gulp
        .src(assetConfig.files.map (value) ->
          path.join assetConfig.devFolder, value
        )
        .pipe concat(assetConfig.filename)
        .pipe specialPipe.call()
        .pipe gulp.dest(path.join assetConfig.prodFolder)

      if assetConfig.filename isnt assetConfig.oldFilename
        try
          fs.unlinkSync path.join(assetConfig.prodFolder, assetConfig.oldFilename)

  reset: ->
    output.title 'Reset views ...'

    @replace true
