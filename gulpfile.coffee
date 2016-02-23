del = require 'del'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
gulp = require 'gulp'
istanbul = require 'gulp-coffee-istanbul'
jsdoc = require 'gulp-jsdoc'
mocha = require 'gulp-mocha'

jsFiles = [ 'lib/**/*.js' ]
coffeeFiles = [ 'src/**/*.coffee' ]
specFiles = [ 'specs/**/*.spec.coffee' ]

gulp.task 'clean', (callback) ->
  del jsFiles, callback

gulp.task 'lint', ->
  gulp.src coffeeFiles
    .pipe coffeelint()
    .pipe coffeelint.reporter()
    .pipe coffeelint.reporter 'fail'

gulp.task 'compile', ['lint'], ->
  gulp.src coffeeFiles
    .pipe coffee({ bare: true })
    .pipe gulp.dest('lib/')

gulp.task 'test', ['compile'], ->
  gulp.src specFiles
    .pipe mocha()

gulp.task 'cover', ['compile'], ->
  gulp.src coffeeFiles
    .pipe istanbul({includeUntested: true})
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src specFiles
        .pipe mocha({reporter: 'spec'})
        .on('error', (err) -> )
        .pipe istanbul.writeReports()

gulp.task 'docs', ['compile'], ->
  gulp.src jsFiles
    .pipe(jsdoc('./docs'))

gulp.task 'dev', ['cover'], ->
  gulp.watch coffeeFiles.concat(specFiles), ['cover']

gulp.task 'build', ['clean', 'lint', 'cover']

gulp.task 'default', ['build']
