
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
    ts: true
    dart: true

    jade: true
    handlebars: true
    mustache: true
    dust: true
    ejs: true

convertFromPrepressorExtension = (filepath, options = {}) ->
  extension = extractExtension(filepath)

  # If there was no valid extension on the passed path, get the extension from the
  # parent path (the file where the passed path came from)
  if extension is '' and options.parentFilename?
    extension = extractExtension(options.parentFilename)

  preprocessorsByExtension = options.preprocessorsByExtension ? DEFAULT_PREPROCESSOR_EXTENSIONS

  for baseExtension, preprocessorExtensions of preprocessorsByExtension
    if extension in preprocessorExtensions
      newExtension = baseExtension

  if newExtension
    filepath.replace(new RegExp("\\.#{extension}$"), ".#{newExtension}")
  else
    filepath

# Creates a new function with pre-filled options. Useful to create a function
# already set with your default preprocessor extensions
convertFromPrepressorExtension.curry = (originalOptions = {}) ->
  (filepath, newOptions = {}) ->
    # Merge passed options on type of curried options
    options = objectAssign {}, originalOptions, newOptions

    convertFromPrepressorExtension filepath, options


module.exports = {
  extractExtension
  convertFromPrepressorExtension

  DEFAULT_PREPROCESSOR_EXTENSIONS
}
