program = require 'commander'
pkg = require '../package.json'
path = require 'path'
fs = require 'fs'
output = require './output'
AssetX = require './assetx'


assetX = (program) ->
  new AssetX path.join(process.cwd(), program.configFile)


output.bigOne()


program
  .version pkg.version
  .option '-C, --config-file [config-file.yml]', 'path to yaml config file (default: assetx.yml)', 'assetx.yml'
  .option '-D, --debug', 'display more information in the console', false


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
    .description 'concat and minify assets'
    .action ->
      assetX(program).concat()

  program
    .command 'replace'
    .description 'replace assetix tags in views'
    .action ->
      assetX(program).replace()

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
