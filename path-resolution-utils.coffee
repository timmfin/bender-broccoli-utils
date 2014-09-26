{ extractExtension } = require('./extension-utils')


MISSING_FILENAME_OPTION_MESSAGE = "Required filename option wasn't passed to resolvePath"

# Resolve a path via the current filename (passed in via options.filename) and
# among any of the passed loadPaths.
resolveDirAndPath = (inputPath, options = {}) ->

  if options.onlyDirectory
    extensionsToCheck = ['']
  else
    extensionsToCheck = options.extensionsToCheck

  dirsToCheck = options.loadPaths ? []
  extraRelativeDirsToCheck = []

  # Some mangle-ing to convert a relative path into a path that is
  # relative to the srcDir (which should have been included in options.loadPaths)
  if /^\.|^\.\.|^\.\.\//.test inputPath
    throw new Error MISSING_FILENAME_OPTION_MESSAGE unless options.filename?

    absolutizedPath = path.join path.dirname(options.filename), inputPath
    [resolvedBaseDir, newRelativePath] = extractBaseDirectoryAndRelativePath absolutizedPath, dirsToCheck
    inputPath = newRelativePath

  # By default, try to look up paths relatively to the parent's path (if relative
  # paths require `./` or `../` set allowRelativeLookupWithoutPrefix to false)
  else if options.allowRelativeLookupWithoutPrefix isnt false
    throw new Error MISSING_FILENAME_OPTION_MESSAGE unless options.filename?
    extraRelativeDirsToCheck.push path.dirname(options.filename)

  # Do the search
  [resolvedDir, relativePath] = searchForPath inputPath, dirsToCheck,
    extensionsToCheck: extensionsToCheck
    extraRelativeDirsToCheck: extraRelativeDirsToCheck

  # Throw a useful error if no path is found. Otherwise return the first successful
  # path found by _searchForPath
  if not resolvedDir?
    inputPathText = "#{inputPath}"

    if extensionsToCheck?.length > 0
      originalExtension = extractExtension inputPath, { onlyAllow: options.onlyAllow }
      inputPathText = "#{inputPath.replace(new RegExp('\\.' + originalExtension + '$'), '')}.#{extensionsToCheck.join('|')}"

    errorMessage = "Could not find #{inputPathText} among: #{dirsToCheck}"
    errorMessage += " (while processing #{options.filename})" if options.filename?
    throw new Error errorMessage
  else
    [resolvedDir, relativePath]

# See if partialPath exists inside any of dirsToCheck optionally with a number of
# different extensions. If/when found, return an array like: [resolvedDir, relativePathFromDir]
searchForPath = (partialPath, dirsToCheck, options = {}) ->

  if not dirsToCheck? or dirsToCheck.length is 0
    throw new Error "Could not lookup #{partialPath} no search directories to check."

  originalExtension = extractExtension partialPath, { onlyAllow: options.onlyAllow }
  extensionsToCheck = options.extensionsToCheck ? [originalExtension]

  if options.allowDirectory is true
    extensionsToCheck.push('')

  # First, look up in base
  for dirToCheck in dirsToCheck
    result = searchForPathInDirWithExtensionsHelper(partialPath, dirToCheck, extensionsToCheck, originalExtension)
    return result if result?

  # Extra dirs to search for paths (but not to be used when determining the resolvedDir)
  extraRelativeDirs = options.extraRelativeDirsToCheck ? []
  ensureRelativeDirsAreSubdirs(extraRelativeDirs, dirsToCheck)  # this check necessary? (e.g. will the error from extractBaseDirectoryAndRelativePath below be good enough?)

  for extraRelativeDir in extraRelativeDirs
    result = searchForPathInDirWithExtensionsHelper(partialPath, extraRelativeDir, extensionsToCheck, originalExtension)

    # If we find in the extra relative dirs, convert the returned resolved dir
    # and path to be relative to one of the original passed in dirsToCheck
    if result?
      [resolvedDir, resolvedPath] = result
      return extractBaseDirectoryAndRelativePath path.join(resolvedDir, resolvedPath), dirsToCheck

  # If not found return empty array (so that destructuring returns undefined
  # instead of error)
  []

searchForPathInDirWithExtensionsHelper = (partialPath, dirToCheck, extensionsToCheck, originalExtension) ->
  if originalExtension is ''
    replaceExtensionRegex = /$/
  else
    replaceExtensionRegex = new RegExp "\\.#{originalExtension}$"

  for extensionToCheck in extensionsToCheck
    pathToCheck = path.join dirToCheck, partialPath

    if extensionToCheck isnt ''
      pathToCheck = pathToCheck.replace(replaceExtensionRegex, ".#{extensionToCheck}")

    if fs.existsSync(pathToCheck)
      partialPath = partialPath.replace(replaceExtensionRegex, ".#{extensionToCheck}") unless extensionToCheck is ''
      return [dirToCheck, partialPath]

# Ensure that the extra relative dirs are a subdirectory of the base dirs to check
ensureRelativeDirsAreSubdirs = (extraRelativeDirs, baseDirs) ->
  if extraRelativeDirs.length > 0

    for extraDir in extraRelativeDirs
      isSubDir = false

      for baseDir in baseDirs when isSubDir is false
        if extraDir.indexOf(baseDir) is 0
          isSubDir = true

      if isSubDir is false
        throw new Error "Extra relative div #{extraDir} isn't contained in any of the base search directories: #{baseDirs.join(', ')}"


module.exports = {
  resolveDirAndPath
  searchForPath
}
