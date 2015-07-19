fs = require 'fs'
yaml = require 'js-yaml'
path = require 'path'
glob = require 'glob'
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
    if options.asset and assetName isnt options.asset
      delete config.assets[assetName]
      continue

    for key in ['devFolder', 'prodFolder', 'devBaseUrl', 'prodBaseUrl', 'cacheBusting']
      assetConfig[key] = config[key] if assetConfig[key] is undefined

    assetConfig.ext = path.extname(assetName).substr 1

    tags = {}
    for viewEngine, defaults of defaultTags
      tags[viewEngine] = selectn('tags.' + viewEngine, assetConfig) or
        selectn('tags.' + viewEngine + '.' + assetConfig.ext, config) or
        selectn('tags.' + assetConfig.ext, defaults)

    assetConfig.tags = tags

    regexp = new RegExp '([.*\/]*?)(.*)(\.' + assetConfig.ext + ')', 'g'

    if assetConfig.cacheBusting is true
      buffers = []

      for globPattern in assetConfig.files
        for file in glob.sync path.join(assetConfig.devFolder, globPattern)
          buffers.push fs.readFileSync(file)

      hash = revHash Buffer.concat(buffers)

      assetConfig.filename = assetName.replace regexp, '$1$2_' + hash + '$3'
    else
      assetConfig.filename = assetName

    oldProdAssets = glob.sync path.join(assetConfig.prodFolder, assetName.replace(regexp, '$1$2*$3'))

    if oldProdAssets.length is 0
      assetConfig.oldFilename = assetName
    else
      assetConfig.oldFilename = oldProdAssets[0].replace assetConfig.prodFolder + '/', ''

    config.assets[assetName] = assetConfig

  throw new Error 'no asset to process' if Object.keys(config.assets).length is 0

  config
