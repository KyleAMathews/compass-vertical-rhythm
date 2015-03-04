chai = require 'chai'
expect = chai.expect
_ = require 'underscore'
parseUnit = require 'parse-unit'

verticalRhythm = require '../src/index'

describe 'rhythm', ->
  it 'should calculate rhythm for rem', ->
    vrREM = verticalRhythm({
      baseFontSize: '21px'
      baseLineHeight: '28px'
      rhythmUnit: 'rem'
    })
    rhythm = vrREM.rhythm
    expect(rhythm(1)).to.equal('1.33333rem')
    expect(rhythm(0.5)).to.equal('0.66667rem')
    expect(rhythm(0.25)).to.equal('0.33333rem')

  it 'should calculate rhythm for em', ->
    vrEM = new verticalRhythm({
      baseFontSize: '24px'
      baseLineHeight: '30px'
      rhythmUnit: 'em'
    })
    rhythm = vrEM.rhythm
    expect(rhythm(1)).to.equal('1.25em')
    expect(rhythm(0.5)).to.equal('0.625em')
    expect(rhythm(0.25)).to.equal('0.3125em')

  it 'should calculate rhythm for px', ->
    vrEM = new verticalRhythm({
      baseFontSize: '24px'
      baseLineHeight: '30px'
      rhythmUnit: 'px'
    })
    rhythm = vrEM.rhythm
    expect(rhythm(1)).to.equal('30px')
    expect(rhythm(0.5)).to.equal('15px')
    expect(rhythm(0.25)).to.equal('7px')

describe 'establishBaseline', ->
  vrREM = verticalRhythm({
    baseFontSize: '21px'
    baseLineHeight: '28px'
    rhythmUnit: 'rem'
  })
  establishBaseline = vrREM.establishBaseline
  it 'should return an object', ->
    expect(establishBaseline()).to.be.instanceof(Object)

  it 'should return an object with a fontSize and lineHeight defined', ->
    result = establishBaseline()
    expect(result.fontSize).to.exist
    expect(result.lineHeight).to.exist

  it 'should return fontSize with percent as its unit', ->
    result = establishBaseline()
    expect(parseUnit(result.fontSize)[1]).to.equal("%")

  it 'should return lineHeight with em as its unit', ->
    result = establishBaseline()
    expect(parseUnit(result.lineHeight)[1]).to.equal("em")

  it 'should return sensible results', ->
    result = establishBaseline()
    expect(result.fontSize).to.equal("150%")
    expect(result.lineHeight).to.equal("1.25em")
