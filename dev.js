const { build, watchdir } = require("estrella");
const { exec } = require('child_process')

build({
  entry: "main.js",
  outfile: "dist/main.js",
  bundle: true,
  watch: true
});

watchdir('src', /main.css/, () => {
  console.log('Building CSS')
  exec('yarn build:css', err => {
    if(!err) {
      console.log('Build CSS succeeded.')
    }
  })
})

// See https://github.com/rsms/estrella/issues/4#issuecomment-633782840
watchdir("output", () => {
  exec('touch main.js')
})

require("serve-http").createServer({
  port: 1234,
  pubdir: require("path").join(__dirname, "dist")
});
