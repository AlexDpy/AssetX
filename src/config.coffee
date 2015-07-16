fs = require 'fs'
yaml = require 'js-yaml'
path = require 'path'
selectn = require 'selectn'
defaultTags = require './tags'
revHash = require 'rev-hash'


module.exports.read = (configFile) ->
  yaml.safeLoad(fs.readFileSync configFile, 'utf8')



module.exports.validate = (config) ->
  errors = []

  errors.push 'config.devFolder is not defined' if config.devFolder is undefined

  errors.push 'config.prodFolder is not defined' if config.prodFolder is undefined

  if config.views is undefined
    errors.push 'config.views is not defined'
  else if not Array.isArray config.views
    errors.push 'config.views must be an array'
  else if config.views.length is 0
    errors.push 'config.views must not be empty'
  else
    for view in config.views
      ext = path.extname(view).substr 1
      if ext not in Object.keys defaultTags
        errors.push 'config.views : only html, twig and jade are supported, "' + view + '" given'

  if config.assets is undefined
    errors.push 'config.assets is not defined'
  else if typeof config.assets isnt 'object'
    errors.push 'config.assets must be an object'
  else
    for name, asset of config.assets
      if asset.files is undefined
        errors.push 'config.assets["' + name + '"].files is not defined'
      else if not Array.isArray asset.files
        errors.push 'config.assets["' + name + '"].files must be an array'

  if errors.length > 0
    throw new Error('Some configuration are missing in your config file, see below :\n' + errors.join '\n')



module.exports.mergeRecursive = (config, options) ->

  for assetName, assetConfig of config.assets
    for key in ['devFolder', 'prodFolder', 'devBaseUrl', 'prodBaseUrl', 'cacheBusting']
      assetConfig[key] = config[key] if assetConfig[key] is undefined

    assetConfig.ext = path.extname(assetName).substr 1

    tags = {}
    for viewEngine, defaults of defaultTags
      tags[viewEngine] = selectn('tags.' + viewEngine, assetConfig) or
        selectn('tags.' + viewEngine + '.' + assetConfig.ext, config) or
        selectn('tags.' + assetConfig.ext, defaults)

    assetConfig.tags = tags

    if assetConfig.cacheBusting is true
      buffers = []
      for file in assetConfig.files
        buffers.push fs.readFileSync(path.join(assetConfig.devFolder, file))

      hash = revHash Buffer.concat(buffers)

      assetConfig.filename = assetName.replace(
        new RegExp '([.*\/]*?)(.*)(\.' + assetConfig.ext + ')', 'g'
        '$1$2_' + hash + '$3'
      )
    else
      assetConfig.filename = assetName

    config.assets[assetName] = assetConfig

  config
