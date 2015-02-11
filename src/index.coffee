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
  roundToNearestHalfLine: false
  minLinePadding: '2px'

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

module.exports = (options) ->
  options = objectAssign(defaults, options)
  return {
    rhythm: rhythm(options)
  }
