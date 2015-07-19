fs = require 'fs'
glob = require 'glob'
path = require 'path'
gulp = require 'gulp'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
mv = require 'mv'
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



  replace: () ->
    output.title 'Replacing'

    replaceTags @



  concat: ->
    output.title 'Concatenating'

    for assetName, assetConfig of @config.assets
      output.log 'Concat ' + assetName

      specialPipe = if assetConfig.ext is 'css' then minifyCss else uglify

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
    output.title 'Resetting views'

    replaceTags @, true



  mv: (src, dest) ->
    output.title 'Moving an asset'

    if @config.assets[src] is undefined
      throw new Error 'No "' + src + '" asset is defined'

    yamlConfig = fs.readFileSync @options.configFile, encoding: 'utf8'
      .replace new RegExp('([\'"]?)' + src + '([\'"]?)([\\t\\s]*?):', 'g'), '$1' + dest + '$2$3:'

    source = src.split '.'
    source.pop()
    destination = dest.split '.'
    destination.pop()

    filename = @config.assets[src].oldFilename.replace source.join('.'), destination.join('.')

    output.log 'Move ' + src + ' to ' + dest
    mv(
      path.join @config.prodFolder, @config.assets[src].oldFilename
      path.join @config.prodFolder, filename
      mkdirp: true
      ((err) ->
        return if err

        output.log 'Update "' + @options.configFile + '"'
        fs.writeFileSync @options.configFile, yamlConfig, encoding: 'utf8'

        for pattern in @config.views
          for viewFile in glob.sync pattern
            match = false
            data = fs.readFileSync viewFile, encoding: 'utf8'
            regExp = new RegExp('assetx (prod|dev):' + src, 'g')

            if data.match regExp
              match = true
              data = data.replace(regExp, 'assetx $1:' + dest)

            if match is true
              output.log 'Update "' + viewFile + '"'
              fs.writeFileSync viewFile, data, encoding: 'utf8'

        new AssetX(@options).replace()
      ).bind @
    )



  replaceTags = (assetX, reset = false) ->
    for pattern in assetX.config.views
      for viewFile in glob.sync pattern
        match = false
        data = fs.readFileSync viewFile, encoding: 'utf8'

        for assetName, assetConfig of assetX.config.assets
          for env in ['dev', 'prod']
            helper = new RegExpHelper(viewFile, env, assetName, assetConfig)
            regExp = helper.getRegExp()
            replacement = if reset then helper.getResetReplacement() else helper.getReplacement()

            if data.match regExp
              match = true
              data = data.replace regExp, replacement
              output.log (if reset then 'Reset' else 'Replace') + ' ' + env + ':' + assetName + ' tag in ' + viewFile

        fs.writeFileSync viewFile, data, encoding: 'utf8' if match is true


