var toExport = {
  Stopwatch: require('./stopwatch')
};

// Gather up all the exports from the following modules
var modulesToLoad = [
  './extension-utils',
  './extract-dir-utils',
  './path-resolution-utils',
  './static-version-utils',
  './project-path-utils',
  './static-conf-utils'
];

for (var i = 0; i < modulesToLoad.length; i++) {
  var mod = require(modulesToLoad[i]);

  for (var key in mod) {
    toExport[key] = mod[key];
  }
}

module.exports = toExport;
