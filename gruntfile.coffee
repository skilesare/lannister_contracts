# https://github.com/ericclemmons/genesis-skeleton/blob/master/Gruntfile.coffee
#
module.exports = (grunt) ->
  _ = require('lodash')
  grunt.util._ = _

  fs = require 'fs'
  path = require 'path'



  #-----------------------------------------------------------------------------
  # Task Aliases
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # default - rebuild
  grunt.registerTask "default", [ "rebuild", ]

  grunt.registerTask "rebuild", ['coffeelint',"buildfiles","lint","browserify"]

  grunt.registerTask "buildfiles", ["coffee", 'cjsx']

  grunt.registerTask "test", ["jasmine_node"]

  grunt.registerTask "testing", ["rebuild","jasmine_node"]

  grunt.registerTask "reactbuild", ["cjsx", "browserify"]

  #-----------------------------------------------------------------------------
  # lint - check everything we can
  # will need --force to get through this
  grunt.registerTask "lint", [
    "jshint",
    "csslint"
  ]

  #-----------------------------------------------------------------------------
  # the config
  #-----------------------------------------------------------------------------
  # constants
  dirs =
      script: __dirname + '/server/'
      testscript: __dirname + '/script/tests/'
      appscript: __dirname + '/app/script/'
      css: __dirname + '/app/css/'
      spec: __dirname + '/server/spec/'
      base: __dirname + "/"
      app: __dirname + "/app/"
      react: __dirname + "/react/"

  #-----------------------------------------------------------------------------
  # What we know how to do
  # the task name is the part after "grunt" or "grunt-contrib"
  # some tasks are multitask, and individual subtasks be run as "exec:startlog"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-csslint"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-jasmine-node"
  grunt.loadNpmTasks 'grunt-jasmine-node-coffee'
  grunt.loadNpmTasks 'grunt-coffee-react'
  grunt.loadNpmTasks('grunt-browserify')
  console.log 'loaded tasks'

  #-----------------------------------------------------------------------------
  # config file
  grunt.initConfig

    # need for templates, which are required for targets
    dirs:
      script: dirs.script
      appscript: dirs.appscript
      css: dirs.css
      testscript: dirs.testscript
      fixtures: dirs.fixtures
      electron: dirs.electron

    #---------------------------------------------------------------------------
    #  cleaner
    clean:
      files: [
        dirs.script + 'app.coffee',
        dirs.script + 'app.js',
        dirs.script + 'app_unit_test.js',
        dirs.script + 'app_e2e_test.js'
        dirs.appscript + 'app.coffee'
        dirs.appscript + 'app.js'
        dirs.appscript + 'app.unit_test.js'
        dirs.script + 'server-spec.js'
        dirs.script + 'electron-spec.js'
        dirs.electron + 'main.js'
        __dirname + '/server-spec.js'
        __dirname + '/components.js'
        __dirname + '/main.js'
      ]

    #---------------------------------------------------------------------------
    # coffeelint checker
    coffeelint:
      files: [
        'Gruntfile.coffee'
        dirs.app + '**\\*.coffee'
        dirs.electron + '**\\*.coffee'
        dirs.script + '*.coffee'
        dirs.spec + '*.coffee'
        dirs.electronspec + '*.coffee'
        dirs.testscript + '*.coffee'
        dirs.appscript + '*.coffee'
        '!' + dirs.script + 'app.coffee'
      ]
      options:
        'no_tabs':
          'level': 'ignore'
        'max_line_length':
          'level': 'ignore'
        'no_unnecessary_fat_arrows':
          'level': 'ignore'

    #---------------------------------------------------------------------------
    # csslint checker
    csslint:
      files: [
        # this target needs template
        '<%= dirs.css %>app.css'
      ]

    #---------------------------------------------------------------------------
    # jshint checker
    jshint:
      # does not use .jshintrc
      options:
        "-W041": false
        "undef": true
        "unused": false
        "shadow": true
        "sub": true
        # /*global */
        "predef": [
          "window",
          "document",
          "$",
          "Backbone",
          "device",
          "setTimeout",
          "Store",
          "_",
          "async",
          "callback",
          "ko",
          "plugins",
          "cordova",
          "Connection",
          "navigator",
          "alert",
          "prompt",
          "confirm"
          "Camera",
          "notification",
          "console",
          "require",
          "Math",
          "module",
          "Lazy",
          "parseDate",
          "moment",
          "StripeCheckout",
          "__dirname"
          "ga"
          "DISQUS"
          "DISQUSWIDGETS"
          "expect"
          "it"
          "describe"
          "jasmine"
          "beforeEach"
          "exports"
          "process"
          "CommentView"
          "RegisterView"
          "LoginView",
          "Q",
          "validateEmail"
          "Buffer"
          "ourVM"
          "escape"
          "unescape"
          "global"

        ]

      files: [
        __dirname + "\\index.js"
        __dirname + "\\server-spec.js"
        __dirname + "\\electron-spec.js"
        __dirname + "\\components.js"
        __dirname + "\\server.js"
        dirs.script + "app.js"
        dirs.appscript + "app.js"
        dirs.app + "\\tests\\**\\*.js"
      ]

    #---------------------------------------------------------------------------
    # coffee compiler
    coffee:
      compile:
        options:
          join: true
        files:[
          {
          '<%= dirs.base %>index.js': [
            dirs.script + '*.coffee',
            '!' + dirs.script + 'app.coffee',
            '!' + dirs.script + 'app_test.coffee',
            '!' + dirs.script + '*_test.coffee',
            "!" + dirs.script + 'cache-loop.coffee',

          ]
          }
          {
          '<%= dirs.base %>server-spec.js': [
            dirs.spec + '*-spec.coffee'
          ]
          }

          {
          '<%= dirs.appscript %>app.js': [
            dirs.appscript + '*.coffee',
            '!' + dirs.appscript + 'app.coffee',
            '!' + dirs.appscript + 'app_test.coffee',
            '!' + dirs.appscript + '*_test.coffee',
          ]
          }
          {
          '<%= dirs.appscript %>app_unit_test.js': [
            dirs.appscript + '*unit_test.coffee',
            '!' + dirs.appscript + 'app_unit_test.coffee'
          ]
          }

        ]
    cjsx:
      compileJoined:
        options:
          join: true
          sourceMap: true
        files:
          'components.js' : [
            'react/*.coffee',
            'react/actions/*.coffee',
            'react/stores/*.coffee',
            'react/components/**/*.coffee'
          ]

    browserify:
      options:
        transform: [require('grunt-react').browserify]
      app:
        src: ['browser.js']
        dest: 'app/script/bundle.js'
    #---------------------------------------------------------------------------
    # less compiler
    less:
      compile:
        files:
          '<%= dirs.css %>app.css': [
            dirs.css + '*.less',
          ]
    jasmine_node:
      options:
        forceExit: true
        match: "."
        matchall: false
        extensions: "js"
        specNameMatcher: "spec"
        coffee: false
        projectRoot: 'sever/spec'
        jUnit:
          report: true
          savePath: "./build/reports/jasmine/"
          useDotNotation: true
          consolidate: true
        all: ["spec"]

    pioneer:
      options:
        features: 'app/tests/features'
        steps: 'app/tests/steps'
        widgets: 'app/tests/widgets'
        format: 'pretty'
        driver: 'chrome'
        coffee: true
    watch:
      scripts:
        files: [
          "**/*.coffee"
          "!app/tests/steps/*.coffee"
          "!**/node_modules/**"
          "!Gruntfile.coffee"
        ]
        tasks: ['rebuild']
      steps:
        files:[

          "app/tests/steps/*.coffee"

        ]
        tasks:
          ['coffee']
      css:
        files: ["**/*.less"]
        tasks: ['rebuild','csslint']
