const elixir = require('laravel-elixir');

require('laravel-elixir-vue-2');

/*
 |--------------------------------------------------------------------------
 | Elixir Asset Management
 |--------------------------------------------------------------------------
 |
 | Elixir provides a clean, fluent API for defining some basic Gulp tasks
 | for your Laravel application. By default, we are compiling the Sass
 | file for your application as well as publishing vendor resources.
 |
 */

elixir((mix) => {
    mix.sass('app.scss')
       .webpack('app.js');
});

var gulp = require('gulp'),
    exec = require('child_process').exec;

gulp.task('phpunit', function () {
    exec('composer exec phpunit ./tests/unit', function (error, stdout) {
        console.log(stdout);
    });
});

// gulp.task('default', function () {
//     gulp.watch('**/*.php', { debounceDelay: 2000 }, ['phpunit']);
// });
