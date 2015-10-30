# AssetX [![Build Status](https://david-dm.org/AlexDpy/AssetX.png)](https://david-dm.org/AlexDpy/AssetX)

> Manage front-end assets

AssetX manages front-end assets and takes care about dev/production environments

## Install

```
$ npm install -g assetx
```

## Usage

### Configuration

AssetX needs a yaml configuration file. Default is ./assetx.yml.

This is the configuration reference :

```yml
# assetx.yml

# (required) where AssetX will find view templates
views:
    - views/**/*.twig

# (required) where AssetX will find dev/prod assets
devFolder: web/.tmp_assets
prodFolder: web/assets

# (required) web path to dev/prod assets
devBaseUrl: /.tmp_assets
prodBaseUrl: /assets

# (optional, default to false) if true, prod assets file names will have a hash based on the dev assets content
# this can be overridden by the --force-cache-busting and --disable-cache-busting options
cacheBusting: true

# (optional) implement this to customize some of the tags AssetX will generate (./src/tags.coffee)
tags:
    twig:
        js: '<script type="text/javascript" src="%src%"></script>'

# (optional) implement this to override the gulp tasks AssetX will pipe (./src/tasks.coffee)
tasks:
    js:
        gulp-uglify: # this key will be used to require the gulp module
            # an array of arguments that will be applied on the module
            - { mangle: false }

# (required) list of assets AssetX will take into account
assets:
    css/style.css: # asset name must be suffixed by the mime-type extension, like .css or .js (path is relative to prodFolder)
        files: # list of dev assets to concatenate (path relative to devFolder)
            - css/**/*.css

    js/app.js:
        files:
            - js/app1.js
            - js/app2.js

    # global options (except 'views') can be override on each asset
    print.css:
        files:
            - css/print/**/*.css
        prodFolder: cdn_assets/css
        prodBaseUrl: 'http://cdn.my-project.com'
        tags:
            twig: '<link rel="stylesheet" href="%src%" media="print">'
        tasks:
            gulp-minify-css:
                - { keepSpecialComments: 0 }
```

### Views

In view templates, insert AssetX [tags](./src/tags.coffee) for each asset defined in the assetx.yml
```twig
{% if app.environment == 'prod' %}
    {#assetx prod:css/style.css#}{#endassetx#}
    {#assetx prod:print.css#}{#endassetx#}
{% else %}
    {#assetx dev:css/style.css#}{#endassetx#}
    {#assetx dev:print.css#}{#endassetx#}
{% endif %}
```

### Run AssetX

```bash
~/my-project $ assetx
```

Some options and other commands are available, just run assetx --help for more information

## License

[MIT](./LICENSE)


## Credits

Inspired by [gassetic](https://github.com/romanschejbal/gassetic)
