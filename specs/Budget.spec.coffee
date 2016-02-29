assert = require 'assert'
chai = require 'chai'
moment = require 'moment'
expect = chai.expect
should = chai.should()
Budget = require '../src/Budget'

# moment throws a warning when bad dates are parsed
# As we're using moment for date validation, we avoid
# this warning to be print in our tests by doing this...
moment.createFromInputFallback = (config) ->
  config._d = new Date config._i

describe 'budget class', ->

  it 'should build instance with moments', ->
    b = new Budget 1, '2016-01-01', '2016-01-30'
    b.should.have.property 'amount'
    b.amount.should.equal 1
    b.startDate.should.be.an.instanceof moment
    b.should.have.property 'endDate'
    b.endDate.should.be.an.instanceof moment
    b.should.have.property 'errors'
    b.errors.should.be.an.instanceof Array
    b.errors.should.be.empty
    b.originalData.should.be.deep.equal
      amount: 1
      startDate: '2016-01-01'
      endDate: '2016-01-30'

  it 'should validate amount', ->
    b1 = new Budget undefined, '2016-01-01', '2016-01-30'
    b1.errors.should.be.deep.equal [
      parameter: 'amount'
      message: 'Required value.'
      value: undefined
    ]
    b2 = new Budget 'invalid', '2016-01-01', '2016-01-30'
    b2.errors.should.be.deep.equal [
      parameter: 'amount'
      message: 'Incorrect type. Expected number.'
      value: 'invalid'
    ]

  it 'should validate startDate', ->
    b1 = new Budget 1, undefined, '2016-01-30'
    b1.errors.should.be.deep.equal [
      parameter: 'startDate'
      message: 'Required value.'
      value: undefined
    ]
    b2 = new Budget 1, 'not a moment', '2016-01-30'
    b2.errors.should.be.deep.equal [
      parameter: 'startDate'
      message: 'Invalid value. Value must be a moment.'
      value: 'not a moment'
    ]

  it 'should validate endDate', ->
    b1 = new Budget 1, '2016-01-01', undefined
    b1.errors.should.be.deep.equal [
      parameter: 'endDate'
      message: 'Required value.'
      value: undefined
    ]
    b2 = new Budget 1, '2016-01-01', 'not a moment'
    b2.errors.should.be.deep.equal [
      parameter: 'endDate'
      message: 'Invalid value. Value must be a moment.'
      value: 'not a moment'
    ]

  describe '#isValid', ->

    it 'should return false when errors', ->
      b = new Budget
      b.isValid().should.be.equal false

    it 'should return true when no errors', ->
      b = new Budget 1, '2016-01-01', '2016-01-30'
      b.isValid().should.be.equal true

  describe '#overlaps', ->

    it 'should throw error when budget is invalid', ->
      b = new Budget 1, '2016-01-01', '2016-01-30'
      expect(b.overlaps.bind(b, undefined)).to.throw Error
      expect(b.overlaps.bind(b, null)).to.throw Error
      expect(b.overlaps.bind(b, {})).to.throw Error

    it 'should return true if budgets overlap', ->
      b1 = new Budget 1, '2016-01-01', '2016-01-30'
      b2 = new Budget 1, '2016-01-30', '2016-02-28'
      b3 = new Budget 1, '2015-12-01', '2016-01-01'
      b4 = new Budget 1, '2016-01-02', '2016-01-29'
      b1.overlaps(b2).should.be.true
      b1.overlaps(b3).should.be.true
      b1.overlaps(b4).should.be.true
      b2.overlaps(b1).should.be.true
      b3.overlaps(b1).should.be.true
      b4.overlaps(b1).should.be.true

    it 'should return false if budgets do not overlap', ->
      b1 = new Budget 1, '2016-01-01', '2016-01-30'
      b2 = new Budget 1, '2016-02-01', '2016-02-28'
      b1.overlaps(b2).should.be.false
      b2.overlaps(b1).should.be.false

  describe '#isApplicable', ->

    it 'should throw when date not a moment', ->
      b = new Budget 1, '2016-01-01', '2016-01-30'
      expect(b.isApplicable.bind(b, undefined)).to.throw Error
      expect(b.isApplicable.bind(b, null)).to.throw Error
      expect(b.isApplicable.bind(b, {})).to.throw Error
      expect(b.isApplicable.bind(b, '2016-01-01')).to.throw Error
      expect(b.isApplicable.bind(b, 'invalid')).to.throw Error

    it 'should return true if budget applicable for date', ->
      b = new Budget 1, '2016-01-01', '2016-01-30'
      b.isApplicable(moment('2016-01-01')).should.be.true
      b.isApplicable(moment('2016-01-01').add(2, 'hour')).should.be.true
      b.isApplicable(moment('2016-01-30')).should.be.true
      b.isApplicable(moment('2016-01-30').add(2, 'hour')).should.be.true
      b.isApplicable(moment('2016-01-15')).should.be.true
      b.isApplicable(moment('2015-01-31')).should.be.false
