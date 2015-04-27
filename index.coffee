toExport =
  Stopwatch: require('./stopwatch')

# Gather up all the exports from the following modules
modulesToLoad = [
  './extension-utils'
  './extract-dir-utils'
  './path-resolution-utils'
  './static-version-utils'
  './static-conf-utils'
]

for mod in modulesToLoad
  for key, value of require(mod)
    toExport[key] = value

module.exports = toExport
