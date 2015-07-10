program = require 'commander'
pkg = require '../package.json'
path = require 'path'
fs = require 'fs'
Output = require './output'
AssetX = require './assetx'


output = new Output()
output.bigOne()


program
  .version pkg.version
  .option '-C, --config-file [config-file.yml]', 'path to yaml config file (default: assetx.yml)', 'assetx.yml'

assetX = new AssetX path.join(process.cwd(), program.configFile), output

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
