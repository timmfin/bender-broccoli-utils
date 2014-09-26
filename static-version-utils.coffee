isAStaticVersionString = (str) ->
  /^(static(?:-\d\.\d+)?)$/.test(str)

containsHardcodedStaticVersionInPath = (str) ->
  /\/(static-\d\.\d+)\//.test(str)


module.exports = {
  isAStaticVersionString
  containsHardcodedStaticVersionInPath
}


