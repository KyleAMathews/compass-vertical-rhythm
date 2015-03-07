objectAssign = require 'object-assign'
convertLength = require 'convert-css-length'
parseUnit = require 'parse-unit'

unit = (length) ->
  return parseUnit(length)[1]

unitLess = (length) ->
  return parseUnit(length)[0]

defaults =
  baseFontSize: '16px'
  baseLineHeight: '24px'
  rhythmUnit: 'rem'
  defaultRhythmBorderWidth: '1px'
  defaultRhythmBorderStyle: 'solid'
  roundToNearestHalfLine: true
  minLinePadding: '2px'

linesForFontSize = (fontSize, options) ->
  convert = convertLength(options.baseFontSize)
  fontInPx = unitLess(convert(fontSize, 'px'))
  baseLineHeightInPx = unitLess(convert(options.baseLineHeight, 'px'))
  minLinePadding = unitLess(convert(options.minLinePadding, 'px'))

  if options.roundToNearestHalfLine
    lines = Math.ceil(2 * fontInPx / baseLineHeightInPx) / 2
  else
    lines = Math.ceil(fontInPx / baseLineHeightInPx)

  # If lines are cramped, include some extra lead.
  if (lines * baseLineHeightInPx - fontInPx) < (minLinePadding * 2)
    if options.roundToNearestHalfLine
      lines += 0.5
    else
      lines += 1

  return lines

rhythm = (options) ->
  convert = convertLength(options.baseFontSize)

  return (lines=1, fontSize=options.baseFontSize, offset=0) ->
    length = ((lines * unitLess(options.baseLineHeight)) - offset)
    length = length + unit(options.baseLineHeight)
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
    lineHeight: convert(options.baseLineHeight, 'em')
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

  return {
    rhythm: rhythm(options)
    establishBaseline: -> establishBaseline(options)
    linesForFontSize: (fontSize) -> linesForFontSize(fontSize, options)
    adjustFontSizeTo: (toSize, lines="auto", fromSize) ->
      adjustFontSizeTo(toSize, lines, fromSize, options)
  }
