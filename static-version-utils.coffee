staticWithOptionalVersionRegex = /^(static(?:-\d\.\d+)?)$/


isAStaticVersionString = (str) ->
  staticWithOptionalVersionRegex.test(str)

isASimpleStaticVersionString = (str) ->
  /^\d+\.\d+$/.test(str)

convertToSimpleVersionString = (str) ->
  str.replace('static-', '')

convertToVersionStringWithStaticPrefix = (str) ->
  if str != "static" and not /^static-/.test(str)
    "static-#{str}"
  else
    str

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

extractMajorVersion = (str) ->
  parseInt(convertToSimpleVersionString(str).split('.')[0], 10)

extractMinorVersion = (str) ->
  parseInt(convertToSimpleVersionString(str).split('.')[1], 10)

module.exports = {
  isAStaticVersionString
  convertToSimpleVersionString
  convertToVersionStringWithStaticPrefix
  containsHardcodedStaticVersionInPath
  splitNameAndVersion
  extractMajorVersion
  extractMinorVersion
}


