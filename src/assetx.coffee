fs = require 'fs'
yaml = require 'js-yaml'
glob = require 'glob'
path = require 'path'
gulp = require 'gulp'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
output = require './output'
RegExpHelper = require './regexp-helper'


module.exports = class AssetX

  constructor: (@configFile) ->
    @config = yaml.safeLoad(fs.readFileSync(@configFile, 'utf8'))
    @validateConfig()

  validateConfig: ->
    errors = []
    errors.push('- the devFolder is not defined') if not @config.devFolder
    errors.push('- the prodFolder is not defined') if not @config.prodFolder
    errors.push('- views are not defined') if not @config.views or not @config.views.length
    errors.push('- assets are not defined') if not @config.assets

    if errors.length > 0
      output.error 'Some configuration are missing in your config file, see below :'
      for error in errors
        output.log error

      process.exit 1

  replace: ->
    output.title 'Replace ...'

    for pattern in @config.views
      for viewFile in glob.sync pattern
        match = false
        data = fs.readFileSync viewFile, encoding: 'utf-8'

        for assetName, assetConfig of @config.assets
          for env in ['dev', 'prod']
            helper = new RegExpHelper(viewFile, env, assetName, @config)
            regExp = helper.getRegExp()

            if data.match regExp
              match = true
              data = data.replace regExp, helper.getReplacement()
              output.log 'Replace ' + env + ':' + assetName + ' tag in ' + viewFile

        fs.writeFileSync viewFile, data, encoding: 'utf-8' if match is true

  concat: ->
    output.title 'Concat ...'

    for assetName, assetConfig of @config.assets
      specialPipe = if path.extname(assetName) is '.css' then minifyCss else uglify

      output.log 'Concat and minify ' + assetName

      gulp
        .src(assetConfig.files.map ((value) ->
          path.join @config.devFolder, value
        ).bind(@))
        .pipe concat(assetName)
        .pipe specialPipe.call()
        .pipe gulp.dest(path.join @config.prodFolder)
