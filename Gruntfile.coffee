module.exports = (grunt) ->
    'use strict'

    require('load-grunt-tasks')(grunt)
    
    grunt.initConfig {
        pkg: grunt.file.readJSON 'package.json'
        banner: """

        /**
         * <%= pkg.name %>
         * Version: <%= pkg.version %>
         * Copyright 2015 - <%= grunt.template.today("yyyy") %> <%= pkg.author %>
         */
        
        """
        clean:
            build: ['build']
            tmp: ['.tmp']
        stylus:
            options:
                compress: false
                paths: ['stylus']
            #     paths: ['src/mixins']
            #     urlfunc: 'embedurl'
            fancy:
                files:
                    '.tmp/build/css/fancy.css': 'src/styl/index.styl'
                    '.tmp/build/css/demo.css': 'src/styl/demo.styl'
        jade:
            serve:
                options:
                    banner: '<%= banner %>'
                    data:
                        debug: true
                        version: '<%= pkg.version %>'
                    # processContent: (content) ->
                    #     content = content.replace(/#{baseurl}/gi, "http://g.tbcdn.cn/forest/dthink/0.0.1")
                    #     return content
                files: [{
                    expand: true
                    cwd: "views/"
                    src: ["*.jade"]
                    dest: ".tmp/build/"
                    ext: ".html"
                }]
            build:
                options:
                    banner: '<%= banner %>'
                    data:
                        debug: false
                        version: '<%= pkg.version %>'
                files: [{
                    expand: true
                    cwd: "views/"
                    src: ["**/*.jade"]
                    dest: "dist/"
                    ext: ".html"
                }]
        copy:
            build:
                expand: true
                cwd: ".tmp/build/"
                src: ["*"]
                dest: "build/"
        connect:
            options:
                port: 9008
                livereload: 42201
                hostname: 'localhost'
                base: '.'
                middleware: (connect, options, middlewares) ->
                    middlewares.unshift (req, res, next) ->
                        console.log req.url
                        res.setHeader('Access-Control-Allow-Origin', '*')
                        res.setHeader('Access-Control-Allow-Methods', '*')
                        return next() if req.url.indexOf(".tmp") isnt -1
                        req.url = "/index.html" if req.url is "/"
                        if req.url.indexOf("http://") isnt -1
                            return next()
                        req.url = "/.tmp/build" + req.url
                        return next()
                    return middlewares
            livereload:
                options:
                    open: true
        watch:
            jade:
                files: 'views/**/*'
                tasks: ['jade:serve']
            stylus:
                files: 'src/styl/**/*.styl'
                tasks: ['stylus']
            livereload:
                options:
                    livereload: '<%= connect.options.livereload %>'
                files: [
                    '.tmp/build/{,*/}*.html'
                    '.tmp/build/**/css/{,*/}*.css'
                    '.tmp/build/**/js/{,*/}*.js'
                    '.tmp/build/**/module/**'
                    '.tmp/build/**/img/**'
                ]
        usebanner:
            dist:
                options:
                    position: 'top'
                    banner: '<%= banner %>'
                files:
                    src: [
                        'build/css/*.css'
                    ]
    }

    grunt.registerTask 'serve', [
        'clean:tmp'
        'stylus'
        'jade:serve'
        'connect:livereload'
        'watch'
    ]
    grunt.registerTask 'server', ['serve']
    grunt.registerTask 'default', ['serve']