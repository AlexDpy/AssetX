program = require 'commander'
pkg = require '../package.json'
path = require 'path'
fs = require 'fs'
output = require './output'
AssetX = require './assetx'


output.bigOne()


program
  .version pkg.version
  .option '-C, --config-file [config-file.yml]', 'path to yaml config file (default: assetx.yml)', 'assetx.yml'

try
  assetX = new AssetX path.join(process.cwd(), program.configFile)


  program
    .command 'run'
    .description 'concat and replace'
    .action ->
      assetX.concat()
      assetX.replace()

  program
    .command 'concat'
    .description 'concat and minify assets'
    .action ->
      assetX.concat()

  program
    .command 'replace'
    .description 'replace assetix tags in views'
    .action ->
      assetX.replace()

  program.parse process.argv

  if program.args.length is 0
    assetX.concat()
    assetX.replace()

catch e
  output.error e
  process.exit 1
