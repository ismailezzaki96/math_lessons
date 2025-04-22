var gulp = require("gulp");
var browserSync = require("browser-sync").create();
// var     inlineCss = require('gulp-inline-css');
var exec = require("child_process").exec;
var path = require("path");

var gulpRanInThisFolder = process.cwd();

var source =  path.join(gulpRanInThisFolder, '/cours.md');

gulp.task("pandoc", function (cb) {
  exec("pandoc_helper html  *.md", function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
    cb(err);
  });
});

gulp.task(
  "pandoc-watch",
  gulp.series("pandoc", function (done) {
    browserSync.reload();
    done();
  }),
);
var cp = require("child_process");
gulp.task("presentation", function () {
  return cp.execFile("pwd");
});

// gulp.task(
//   "presentation",
//   function (cb) {
//     exec("presentation-mode");
//   },
// );

gulp.task(
  "default",
  gulp.series("pandoc", "presentation", function () {
    browserSync.init({
      ghostMode: false,
      notify: true,
      scrollProportionally: true,
      scrollThrottle: 0,
      scrollRestoreTechnique: "window.name",
      scrollElements: [],
      scrollElementMapping: [],
      watch: true,
      open: true,
      browser: "dmenuhandler",
      injectChanges: false,
      port: 3010,
      server: {
        baseDir: "./",
      },

  }, function(err, bs) {
    bs.io.sockets.on('connection', function(socket) {
      socket.on('edit', function (data) {
  exec(`open-nvim  ${data.toString()} "${source}"`, function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
  });
      });
   socket.on('ggb', function (data) {
                console.log(`${gulpRanInThisFolder}/${data.toString()}`);
  exec(`geogebra-fix  ${gulpRanInThisFolder}/${data.toString()} `, function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
  });
      });

    });
  });
    // add browserSync.reload to the tasks array to make
    // all browsers reload after tasks are complete.
    gulp.watch(["*.md", "./templates/*"], gulp.series("pandoc-watch"));
  }),
);
