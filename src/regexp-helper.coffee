path = require 'path'

defaults =

  html:
    startTag: '<!--assetx %env%:%assetName%-->'
    endTag: '<!--endassetx-->'
    tags:
      css: '<link rel="stylesheet" href="%src%">'
      js: '<script src="%src%"></script>'

  twig:
    startTag: '{#assetx %env%:%assetName%#}'
    endTag: '{#endassetx#}'
    tags:
      css: '<link rel="stylesheet" href="%src%">'
      js: '<script src="%src%"></script>'

  jade:
    startTag: '//assetx %env%:%assetName%'
    endTag: '//endassetx'
    tags:
      css: 'link(rel="stylesheet", href="%src%")'
      js: 'script(src="%src%")'

module.exports = class RegExpHelper

  constructor: (@viewFile, @env, @assetName, @config) ->
    @viewEngine = path.extname(@viewFile).substr(1)
    throw new Error('viewEngine "' + @viewEngine + '" is not defined') if not defaults[@viewEngine]

    @assetExt = path.extname(@assetName).substr(1)
    throw new Error('only *.css and *.js assets files are supported, "' + @assetName + '" given') if @assetExt not in ['css', 'js']

    @startTag = defaults[@viewEngine].startTag
      .replace '%env%', @env
      .replace '%assetName%', @assetName

    @endTag = defaults[@viewEngine].endTag

    if @config.assets[@assetName].tag
      @tagPattern = @config.assets[@assetName].tag
    else if @config.tags and @config.tags[@viewEngine] and @config.tags[@viewEngine][@assetExt]
      @tagPattern = @config.tags[@viewEngine][@assetExt]
    else
      @tagPattern = defaults[@viewEngine].tags[@assetExt]


  getRegExp: ->
    return new RegExp('([\\s\\t]+?)' + @startTag + '([\\s\\S]*?)' + @endTag, 'g')


  getReplacement: ->
    return '$1' + @startTag + @getTags() + '$1' + @endTag


  getTags: ->
    html = ''

    if @env is 'prod'
      html += '$1' + @tagPattern.replace('%src%', path.join(@config.prodBaseUrl, @assetName))
    else
      for devAsset in @config.assets[@assetName].files
        html += '$1' + @tagPattern.replace('%src%', path.join(@config.devBaseUrl, @assetName))

    html
