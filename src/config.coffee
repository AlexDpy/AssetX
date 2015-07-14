fs = require 'fs'
yaml = require 'js-yaml'
path = require 'path'


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
      if ext not in ['html', 'twig', 'jade']
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
