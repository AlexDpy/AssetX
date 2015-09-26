program = require 'commander'
pkg = require '../package.json'
path = require 'path'
fs = require 'fs'
output = require './output'
AssetX = require './assetx'


assetX = (program) ->

  options =
    configFile: path.join(process.cwd(), program.configFile)
    debug: program.debug or false
    asset: program.asset
    forceCacheBusting: program.forceCacheBusting or false
    disableCacheBusting: program.disableCacheBusting or false

  new AssetX options


output.bigOne()


program
  .version pkg.version
  .option '-C, --config-file [path/to/config-file.yml]', 'path to yaml config file (default: assetx.yml)', 'assetx.yml'
  .option '-D, --debug', 'display more information in the console'
  .option '-A, --asset [assetName]', 'the asset to process (default to all)'
  .option '--force-cb, --force-cache-busting', 'force cache busting, even if cache busting configuration is set to false'
  .option '--disable-cb, --disable-cache-busting', 'disable cache busting, even if cache busting configuration is set to true'

try
  program
    .command 'run'
    .description 'concat and replace'
    .action ->
      assetX = assetX(program)
      assetX.concat()
      assetX.replace()

  program
    .command 'concat'
    .description 'concat assets'
    .action ->
      assetX(program).concat()

  program
    .command 'replace'
    .description 'replace assetx tags in views'
    .action ->
      assetX(program).replace()

  program
    .command 'reset'
    .description 'reset all "assetx" tags in views'
    .action ->
      assetX(program).reset()

  program
    .command 'mv'
    .arguments '<src> <dest>'
    .description 'move an asset'
    .action (src, dest) ->
      program.asset = src
      assetX(program).mv(src, dest)

  program.parse process.argv

  if program.args.length is 0
    assetX = assetX(program)
    assetX.concat()
    assetX.replace()

catch e
  output.error e

  if program.debug
    throw e

  process.exit 1
