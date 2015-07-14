module.exports =

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
