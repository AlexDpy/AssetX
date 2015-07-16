path = require 'path'
glob = require 'glob'
defaultTags = require './tags'

module.exports = class RegExpHelper

  constructor: (@viewFile, @env, @assetName, @assetConfig) ->
    @viewEngine = path.extname(@viewFile).substr 1
    throw new Error('viewEngine "' + @viewEngine + '" is not defined') if not defaultTags[@viewEngine]

    throw new Error('only *.css and *.js assets files are supported, "' + @assetName + '" given') if @assetConfig.ext not in ['css', 'js']

    @startTag = defaultTags[@viewEngine].startTag
      .replace '%env%', @env
      .replace '%assetName%', @assetName

    @endTag = defaultTags[@viewEngine].endTag

    @tagPattern = @assetConfig.tags[@viewEngine]


  getRegExp: ->
    return new RegExp('([\\s\\t]+?)' + @startTag + '([\\s\\S]*?)' + @endTag, 'g')


  getReplacement: ->
    return '$1' + @startTag + @getTags() + '$1' + @endTag


  getTags: ->
    html = ''

    if @env is 'prod'
      html += '$1' + @tagPattern.replace('%src%', path.join(@assetConfig.prodBaseUrl, @assetConfig.filename))
    else
      for globPattern in @assetConfig.files
        for file in glob.sync path.join(@assetConfig.devFolder, globPattern)
          html += '$1' + @tagPattern.replace('%src%', file.replace(@assetConfig.devFolder, @assetConfig.devBaseUrl))

    html
