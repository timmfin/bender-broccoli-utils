extractBaseDirectory = (filepath, baseDirs) ->
  for baseDir in baseDirs
    baseDir = "#{baseDir}/" unless baseDir[baseDir.length - 1] is '/'  # Ensure trailing slash

    if filepath.indexOf(baseDir) is 0
      return baseDir

  throw new Error "#{filepath} isn't in any of #{baseDirs.join(', ')}"

extractBaseDirectoryAndRelativePath = (filepath, baseDirs) ->
  resolvedBaseDir = extractBaseDirectory filepath, baseDirs
  relativePath = filepath.replace(resolvedBaseDir, '')
  [resolvedBaseDir, relativePath]

stripBaseDirectory = (filepath, baseDirs) ->
  [resolvedBaseDir, relativePath] = extractBaseDirectoryAndRelativePath filepath, baseDirs
  relativePath



module.exports = {
  stripBaseDirectory
  extractBaseDirectory
  extractBaseDirectoryAndRelativePath

}

