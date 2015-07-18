colors = require 'colors'

module.exports.bigOne = ->
  console.log ''
  console.log '    ', colors.blackBG '                                             '
  console.log '    ', colors.blackBG '     ' + colors.yellow('/\\') + '                              ' + colors.yellow('\\\\  //') + '  '
  console.log '    ', colors.blackBG '    /__\\    ' + colors.yellow('____   ____   ____ __ __') + '  \\\\//   '
  console.log '    ', colors.blackBG '   /____\\  |____  |____  |__     |    //\\\\   '
  console.log '    ', colors.blackBG '  ' + colors.yellow('/      \\') + '  ____|  ____| |____   |   ' + colors.yellow('//  \\\\') + '  '
  console.log '    ', colors.blackBG '                                             '
  console.log ''

module.exports.log = (text) ->
  console.log '    ' + text

module.exports.error = (text) ->
  console.error '  ' + colors.redBG text

module.exports.title = (text) ->
  console.log '  ' + colors.yellow.underline text + ' ...'
