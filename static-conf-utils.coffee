path = require('path')
fs = require('fs')

staticConfPathForDirectory = (dirPath) ->
  path.join(dirPath, "static", "static_conf.json")

hasStaticConfFile = (dirPath) ->
  confPath = staticConfPathForDirectory dirPath
  fs.existsSync confPath

readStaticConfInDirectory = (dirPath) ->
  content = fs.readFileSync(staticConfPathForDirectory(dirPath)).toString()
  JSON.parse content


module.exports = {
  hasStaticConfFile
  readStaticConfInDirectory
}


