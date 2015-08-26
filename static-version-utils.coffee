staticWithOptionalVersionRegex = /^(static(?:-\d\.\d+)?)$/


isAStaticVersionString = (str) ->
  staticWithOptionalVersionRegex.test(str)

isASimpleStaticVersionString = (str) ->
  /^\d+\.\d+$/.test(str)

convertToSimpleVersionString = (str) ->
  str.replace('static-', '')

containsHardcodedStaticVersionInPath = (str) ->
  /\/(static-\d\.\d+)\//.test(str)

# Can deal with
#   - name              => ["name", undefined]
#   - name@1.2          => ["name", "1.2"]
#   - name@static-1.2   => ["name", "1.2"]
#   - name@static       => ["name", undefined]
#   - name@local        => ["name", undefined]
splitNameAndVersion = (str) ->
  [name, version] = str.split('@')

  if version in ['static', 'local', undefined]
    [name, version]
  else if isAStaticVersionString(version)
    [name, convertToSimpleVersionString(version)]
  else if isASimpleStaticVersionString(version)
    [name, version]
  else
    throw new Error("Invalid name and version string: #{str}")

module.exports = {
  isAStaticVersionString
  convertToSimpleVersionString
  containsHardcodedStaticVersionInPath
  splitNameAndVersion
}


