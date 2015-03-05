path = require('path')
fs = require('fs')

{ extractBaseDirectoryAndRelativePath } = require('./extract-dir-utils')
{ extractExtension } = require('./extension-utils')


missingFilenameOptionMessage = (inputPath, options) ->
  "Required filename option wasn't passed to resolvePath (for #{inputPath})"

# Resolve a path via the current filename (passed in via options.filename) and
# among any of the passed loadPaths.
resolveDirAndPath = (inputPath, options = {}) ->

  # Don't try and resolve paths that are already absolute
  return inputPath if inputPath?.length > 0 and inputPath[0] is '/'

  if options.onlyDirectory
    extensionsToCheck = ['']
  else
    extensionsToCheck = options.extensionsToCheck

  dirsToCheck = options.loadPaths ? []
  extraRelativeDirsToCheck = []

  isReturningAnArray = options.allowMultipleResultsFromSameDirectory # or ...

  # Some mangle-ing to convert a relative path into a path that is
  # relative to the srcDir (which should have been included in options.loadPaths)
  if /^\.|^\.\.|^\.\.\//.test inputPath
    if not options.filename?
      throw new Error missingFilenameOptionMessage(inputPath, options)

    absolutizedPath = path.join path.dirname(options.filename), inputPath
    [resolvedBaseDir, newRelativePath] = extractBaseDirectoryAndRelativePath absolutizedPath, dirsToCheck
    inputPath = newRelativePath

  # By default, try to look up paths relatively to the parent's path (if relative
  # paths require `./` or `../` set allowRelativeLookupWithoutPrefix to false)
  else if options.allowRelativeLookupWithoutPrefix isnt false
    if not options.filename?
      throw new Error missingFilenameOptionMessage(inputPath, options)

    extraRelativeDirsToCheck.push path.dirname(options.filename)

  # Do the search
  results = searchForPath inputPath, dirsToCheck,
    extensionsToCheck: extensionsToCheck
    extraRelativeDirsToCheck: extraRelativeDirsToCheck
    onlyAllow: options.onlyAllow
    allowDirectory: options.allowDirectory
    allowMultipleResultsFromSameDirectory: options.allowMultipleResultsFromSameDirectory

  if isReturningAnArray
    anythingFound = results.length > 0 and results[0][0]?
  else
    anythingFound = results[0]?


  # Throw a useful error if no path is found. Otherwise return the first successful
  # path found by _searchForPath
  if not anythingFound
    inputPathText = "#{inputPath}"

    if extensionsToCheck?.length > 0
      originalExtension = extractExtension inputPath, { onlyAllow: options.onlyAllow }
      inputPathText = "#{inputPath.replace(new RegExp('\\.' + originalExtension + '$'), '')}.#{extensionsToCheck.join('|')}"

    errorMessage = "Could not find #{inputPathText} among: #{dirsToCheck}"
    errorMessage += " (while processing #{options.filename})" if options.filename?
    throw new Error errorMessage
  else
    results

resolvePath = (inputPath, options) ->
  [resolvedDir, resolvedPath] = resolveDirAndPath inputPath, options
  path.join resolvedDir, resolvedPath

# See if partialPath exists inside any of dirsToCheck optionally with a number of
# different extensions. If/when found, return an array like: [resolvedDir, relativePathFromDir]
searchForPath = (partialPath, dirsToCheck, options = {}) ->

  if not dirsToCheck? or dirsToCheck.length is 0
    throw new Error "Could not lookup #{partialPath} no search directories to check."

  originalExtension = extractExtension partialPath, { onlyAllow: options.onlyAllow }
  extensionsToCheck = options.extensionsToCheck ? [originalExtension]

  isReturningAnArray = options.allowMultipleResultsFromSameDirectory # or ...

  if options.allowDirectory is true
    extensionsToCheck.push('')

  # First, look up in base
  for dirToCheck in dirsToCheck
    results = searchForPathInDirWithExtensionsHelper(partialPath, dirToCheck, extensionsToCheck, originalExtension, { allowMultipleResults: options.allowMultipleResultsFromSameDirectory })

    if results.length > 0
      return if isReturningAnArray then results else results[0]

  # Extra dirs to search for paths (but not to be used when determining the resolvedDir)
  extraRelativeDirs = options.extraRelativeDirsToCheck ? []
  ensureRelativeDirsAreSubdirs(extraRelativeDirs, dirsToCheck)  # this check necessary? (e.g. will the error from extractBaseDirectoryAndRelativePath below be good enough?)

  for extraRelativeDir in extraRelativeDirs
    results = searchForPathInDirWithExtensionsHelper(partialPath, extraRelativeDir, extensionsToCheck, originalExtension, { allowMultipleResults: options.allowMultipleResultsFromSameDirectory })

    # If we find in the extra relative dirs, convert the returned resolved dir
    # and path to be relative to one of the original passed in dirsToCheck
    transformedResults = for [resolvedDir, resolvedPath] in results
      extractBaseDirectoryAndRelativePath path.join(resolvedDir, resolvedPath), dirsToCheck

    if transformedResults.length > 0
      return if isReturningAnArray then transformedResults else transformedResults[0]

  # If not found return empty array (so that destructuring returns undefined
  # instead of error)
  []

searchForPathInDirWithExtensionsHelper = (partialPath, dirToCheck, extensionsToCheck, originalExtension, options = {}) ->
  if originalExtension is ''
    replaceExtensionRegex = /$/
  else
    replaceExtensionRegex = new RegExp "\\.#{originalExtension}$"

  results = []

  for extensionToCheck in extensionsToCheck
    if extensionToCheck isnt ''
      modifiedPartialPath = partialPath.replace(replaceExtensionRegex, ".#{extensionToCheck}")
    else
      modifiedPartialPath = partialPath

    pathToCheck = path.join dirToCheck, modifiedPartialPath

    if fs.existsSync(pathToCheck)
      results.push [dirToCheck, modifiedPartialPath]
      break unless options.allowMultipleResults

  results


# Ensure that the extra relative dirs are a subdirectory of the base dirs to check
ensureRelativeDirsAreSubdirs = (extraRelativeDirs, baseDirs) ->
  if extraRelativeDirs.length > 0

    for extraDir in extraRelativeDirs
      isSubDir = false

      for baseDir in baseDirs when isSubDir is false
        if extraDir.indexOf(baseDir) is 0
          isSubDir = true
          break

      if isSubDir is false
        throw new Error "Extra relative div #{extraDir} isn't contained in any of the base search directories: #{baseDirs.join(', ')}"


module.exports = {
  resolvePath
  resolveDirAndPath
  searchForPath
}
