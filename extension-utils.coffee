objectAssign = require('object-assign')
path = require('path')


extractExtension = (filepath, options = {}) ->
  extension = path.extname(filepath).slice(1)

  if options.onlyAllow? and not(extension in options.onlyAllow)
    extension = ''

  extension


DEFAULT_PREPROCESSOR_EXTENSIONS =
  css:
    sass: true
    scss: true
    less: true
    stylus: true

  js:
    coffee: true
    iced: true
    jsx: true
    cjsx: true
    ts: true
    dart: true

    jade: true
    handlebars: true
    mustache: true
    dust: true
    ejs: true

convertFromPreprocessorExtension = (filepath, options = {}) ->
  originalExtension = extension = extractExtension(filepath, options)

  # If there was no valid extension on the passed path, get the extension from the
  # parent path (the file where the passed path came from)
  if extension is '' and options.parentFilename?
    extension = extractExtension(options.parentFilename, options)

  preprocessorsByExtension = options.preprocessorsByExtension ? DEFAULT_PREPROCESSOR_EXTENSIONS

  for baseExtension, preprocessorExtensions of preprocessorsByExtension
    if preprocessorExtensions[extension]?
      newExtension = baseExtension
      break

  if newExtension and originalExtension is ''
    filepath + ".#{newExtension}"
  else if newExtension
    filepath.replace(new RegExp("\\.#{originalExtension}$"), ".#{newExtension}")
  else
    filepath

# Creates a new function with pre-filled options. Useful to create a function
# already set with your default preprocessor extensions
convertFromPreprocessorExtension.curry = (originalOptions = {}) ->
  (filepath, newOptions = {}) ->
    # Merge passed options on type of curried options
    options = objectAssign {}, originalOptions, newOptions

    convertFromPreprocessorExtension filepath, options

invertPreprocessorsByExtensionMap = (preprocessorsByExtension) ->
  result = Object.create(null)

  for origExt, subMap of preprocessorsByExtension
    for processedExt in Object.keys(subMap)
      result[processedExt] ?= Object.create(null)
      result[processedExt][origExt] = true

  result

allPossibleCompiledExtensionsFor = (ext, options) ->
  # Trim leading dot if provided
  ext = ext[1..] if ext?[0] is '.'

  invertedMap = invertPreprocessorsByExtensionMap(options.preprocessorsByExtension)

  if invertedMap?[ext]?
    result = Object.keys(invertedMap[ext])
  else
    result = []

  result.push(ext) unless options?.excludeOwnExtension is true
  result


module.exports = {
  extractExtension
  convertFromPreprocessorExtension

  invertPreprocessorsByExtensionMap
  allPossibleCompiledExtensionsFor

  DEFAULT_PREPROCESSOR_EXTENSIONS
}
