module.exports = (grunt) ->
    'use strict'

    require('load-grunt-tasks')(grunt)
    
    grunt.initConfig {
        pkg: grunt.file.readJSON 'package.json'
        banner: """

        /**
         * PROJECT: <%= pkg.name %> v<%= pkg.version %>
         * AUTHOR: <%= pkg.author.name %>
         * EMAIL: <%= pkg.author.email %>
         * LICENSE: <%= pkg.license %>
         */
        
        """
        clean:
            build: ['build']
            tmp: ['.tmp']
        coffee:
            compile:
                options: {
                    bare: true
                }
                expand: true
                flatten: true
                cwd: 'src/coffee'
                src: ['*.coffee']
                dest: '.tmp/tmp/js/'
                ext: '.js'
        concat:
            options:
                banner: '<%= banner %>'
                stripBanners: false
            dist:
                src: [
                    'src/vendor/pace.js'
                    'src/vendor/require.js'
                    'src/vendor/jquery.js'
                    'src/vendor/waves.js'
                    '.tmp/tmp/js/init.js'
                ]
                dest: '.tmp/build/js/<%= pkg.name %>.js'
        uglify:
            options:
                mangle:
                    except: ['require']
                normalizeDirDefines: true
                skipDirOptimize: false
                preserveComments: false
            js:
                options:
                    banner: '<%= banner %>'
                files:[{
                    expand: true
                    cwd: '.tmp/build/'
                    src: ['js/*.js']
                    dest: 'build/'
                    ext: '.min.js'
                }]
        stylus:
            options:
                compress: false
                paths: ['stylus']
            #     paths: ['src/mixins']
            #     urlfunc: 'embedurl'
            serve:
                files:
                    '.tmp/build/css/<%= pkg.name %>.css': 'src/styl/index.styl'
                    '.tmp/build/css/demo.css': 'src/styl/demo.styl'
        postcss:
            serve:
                options:
                    map: false
                    processors: [
                        require('pixrem')()
                        # require('autoprefixer')({browsers: '> 1%, last 2 versions, Firefox ESR, Opera 12.1'})
                        require('autoprefixer')({browsers: 'last 2 versions'})
                    ]
                src: ['.tmp/build/css/*.css']
            build:
                options:
                    map: false
                    processors: [
                        require('pixrem')()
                        require('autoprefixer')({browsers: '> 1%, last 2 versions, Firefox ESR, Opera 12.1'})
                        require('cssnano')
                    ]
                src: ['.tmp/build/css/*.css']
        usebanner:
            dist:
                options:
                    position: 'top'
                    banner: '<%= banner %>'
                files:
                    src: [
                        '.tmp/build/css/*.css'
                    ]
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
                    src: ["*.jade"]
                    dest: "build/"
                    ext: ".html"
                }]
        copy:
            build:
                expand: true
                cwd: ".tmp/build/"
                src: ["*/**"]
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
            coffee:
                files: 'src/coffee/**/*.coffee'
                tasks: ['coffee', 'concat']
            jade:
                files: 'views/**/*'
                tasks: ['jade:serve']
            stylus:
                files: 'src/styl/**/*.styl'
                tasks: ['stylus', 'postcss:serve']
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
    }

    grunt.registerTask 'build', [
        'clean:*'
        'coffee', 'concat', 'uglify'                #Build JS
        'stylus', 'postcss:build','usebanner'       #Build CSS
        'jade:build'                                #Build HTML
        'copy'                                      #Copy Files To Build Dir
    ]

    grunt.registerTask 'serve', [
        'clean:tmp'
        'coffee', 'concat'
        'stylus', 'postcss:serve'
        'jade:serve'
        'connect:livereload', 'watch'
    ]
    grunt.registerTask 'server', ['serve']
    grunt.registerTask 'default', ['serve']