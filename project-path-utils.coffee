extractProjectAndVersionFromPath = (filepath) ->
  if filepath
    tokens = filepath.split('/')
    projectIndex = null

    for i in [tokens.length-1..0] by -1
      token = tokens[i]

      if isAStaticVersionString token
        projectIndex = i - 1
        version = RegExp.$1

    if projectIndex >= 0
      [tokens[projectIndex], version]
    else
      [undefined, undefined]

# Given a path like "project/static/sass/bla.sass" or "/home/user/dev/project2/static/html/index.html",
# extracts out the project name (by looking at the part before "/static/")
extractProjectFromPath = (filepath) ->
  [project, version] = extractProjectAndVersionFromPath filepath
  project


module.exports = {
  extractProjectFromPath
  extractProjectAndVersionFromPath
}


