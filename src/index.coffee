objectAssign = require 'object-assign'
convertLength = require 'convert-css-length'
parseUnit = require 'parse-unit'

unit = (length) ->
  return parseUnit(length)[1]

unitLess = (length) ->
  return parseUnit(length)[0]

defaults =
  baseFontSize: '16px'
  baseLineHeight: 1.5
  rhythmUnit: 'rem'
  defaultRhythmBorderWidth: '1px'
  defaultRhythmBorderStyle: 'solid'
  roundToNearestHalfLine: true
  minLinePadding: '2px'

linesForFontSize = (fontSize, options) ->
  convert = convertLength(options.baseFontSize)
  fontSizeInPx = unitLess(convert(fontSize, 'px'))
  lineHeightInPx = unitLess(options.baseLineHeightInPx)
  minLinePadding = unitLess(convert(options.minLinePadding, 'px'))

  if options.roundToNearestHalfLine
    lines = Math.ceil(2 * fontSizeInPx / lineHeightInPx) / 2
  else
    lines = Math.ceil(fontSizeInPx / lineHeightInPx)

  # If lines are cramped, include some extra lead.
  if (lines * lineHeightInPx - fontSizeInPx) < (minLinePadding * 2)
    if options.roundToNearestHalfLine
      lines += 0.5
    else
      lines += 1

  return lines

rhythm = (options) ->
  convert = convertLength(options.baseFontSize)

  return (lines=1, fontSize=options.baseFontSize, offset=0) ->
    length = ((lines * unitLess(options.baseLineHeightInPx)) - offset) + "px"
    rhythmLength = convert(length, options.rhythmUnit, fontSize)
    if unit(rhythmLength) is "px"
      rhythmLength = Math.floor(unitLess(rhythmLength)) + unit(rhythmLength)

    # Limit to 5 decimals.
    return parseFloat(unitLess(rhythmLength).toFixed(5)) + unit(rhythmLength)

establishBaseline = (options) ->
  convert = convertLength(options.baseFontSize)

  # Set these values on html in your css.
  return {
    # 16px is the default browser font size.
    # Set base fontsize in percent as older browsers (or just IE6) behave
    # weird otherwise.
    fontSize: (unitLess(options.baseFontSize)/16) * 100 + "%"

    # Webkit has bug that prevents setting line-height in REMs on <html>
    # Always setting line-height in em works around that even if we use
    # REMs elsewhere.
    lineHeight: convert(options.baseLineHeightInPx, 'em')
  }

adjustFontSizeTo = (toSize, lines, fromSize, options) ->
  unless fromSize? then fromSize = options.baseFontSize

  if unit(toSize) is "%"
    toSize = unitLess(options.baseFontSize) * (unitLess(toSize)/100) + "px"

  convert = convertLength(options.baseFontSize)
  fromSize = convert(fromSize, 'px')
  toSize = convert(toSize, 'px', fromSize)
  r = rhythm(options)

  if lines is "auto"
    lines = linesForFontSize(toSize, options)

  return {
    fontSize: convert(toSize, options.rhythmUnit, fromSize)
    lineHeight: r(lines, fromSize)
  }

module.exports = (options) ->
  # Don't override defaults
  defaultsCopy = JSON.parse(JSON.stringify(defaults))

  options = objectAssign(defaultsCopy, options)

  # Backwards compatability. If baseLineHeight is in pixels, convert to unitless
  # value. Also set line height in pixels as it's used several places.
  convert = convertLength(options.baseFontSize)
  if unit(options.baseLineHeight)
    fontSizeInPx = unitLess(convert(options.baseFontSize, 'px'))
    lineHeight = convert(options.baseLineHeight, 'px')
    options.baseLineHeightInPx = lineHeight
    options.baseLineHeight = unitLess(lineHeight) / fontSizeInPx
  else
    options.baseLineHeightInPx = "#{unitLess(options.baseFontSize) * options.baseLineHeight}px"

  return {
    rhythm: rhythm(options)
    establishBaseline: -> establishBaseline(options)
    linesForFontSize: (fontSize) -> linesForFontSize(fontSize, options)
    adjustFontSizeTo: (toSize, lines="auto", fromSize) ->
      adjustFontSizeTo(toSize, lines, fromSize, options)
  }
