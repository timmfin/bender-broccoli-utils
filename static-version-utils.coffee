staticWithOptionalVersionRegex = /^(static(?:-\d\.\d+)?)$/


isAStaticVersionString = (str) ->
  staticWithOptionalVersionRegex.test(str)

convertToSimpleVersionString = (str) ->
  staticWithOptionalVersionRegex.replace('static-', '')

containsHardcodedStaticVersionInPath = (str) ->
  /\/(static-\d\.\d+)\//.test(str)


module.exports = {
  isAStaticVersionString
  convertToSimpleVersionString
  containsHardcodedStaticVersionInPath
}


