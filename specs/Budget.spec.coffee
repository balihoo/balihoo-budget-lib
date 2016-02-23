assert = require 'assert'
chai = require 'chai'
expect = chai.expect
should = chai.should()
budget = require '../src/Budget'

describe 'budget', ->

  describe '#validate', ->

    it 'should check amount property existence', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-01-01', endDate: '2016-04-30' }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { parameter: 'amount', message: 'Required value.', value: undefined }
      ]

    it 'should check amount is a number', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 'invalid' }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { parameter: 'amount', message: 'Incorrect type. Expected number.', value: 'invalid' }
      ]

    it 'should check startDate property existence', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { endDate: '2016-04-30', amount: 750 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { parameter: 'startDate', message: 'Required value.', value: undefined }
      ]

    it 'should check startDate property format', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '20160101', endDate: '2016-04-30', amount: 750 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { parameter: 'startDate', message: 'Invalid value. Value must match required pattern.', value: '20160101' }
      ]

    it 'should check endDate property existence', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-01-01', amount: 750 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { parameter: 'endDate', message: 'Required value.', value: undefined }
      ]

    it 'should check startDate property format', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-01-01', endDate: '20160430', amount: 750 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { parameter: 'endDate', message: 'Invalid value. Value must match required pattern.', value: '20160430' }
      ]

    it 'should check overlapping dates (start and end dates are the same)', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 750 }
        { startDate: '2016-05-31', endDate: '2016-06-30', amount: 999 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { message: 'Overlapping dates in budgets: 2016-05-31 (endDate) overlaps with 2016-05-31 (startDate)' }
      ]

    it 'should check overlapping dates (2nd interval overlap 1st)', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-05-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 750 }
        { startDate: '2016-06-01', endDate: '2016-06-30', amount: 999 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        { message: 'Overlapping dates in budgets: 2016-01-01 (startDate) overlaps with 2016-05-01 (startDate)' }
      ]

  describe '#findApplicable', ->

    it 'should return undefined if no budget for specified date', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 750 }
        { startDate: '2016-06-01', endDate: '2016-06-30', amount: 999 }
      ]
      expect(budget.findApplicable(budgets, '2018-01-01')).to.be.undefined

    it 'should return budget in interval (between test)', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 750 }
        { startDate: '2016-06-01', endDate: '2016-06-30', amount: 999 }
      ]
      budget.findApplicable(budgets, '2016-06-15').should.equal 999

    it 'should return budget in interval (inclusion test)', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 750 }
        { startDate: '2016-06-01', endDate: '2016-06-30', amount: 999 }
      ]
      budget.findApplicable(budgets, '2016-05-01').should.equal 750

    it 'should use today\'s date if no date specified', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-02-15', amount: 500 }
        { startDate: '2016-02-20', endDate: '2155-05-31', amount: 750 }
      ]
      budget.findApplicable(budgets).should.equal 750

  describe '#validateAndFindApplicable', ->

    it 'should return budget for date', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 750 }
        { startDate: '2016-06-01', endDate: '2016-06-30', amount: 999 }
      ]
      budget.validateAndFindApplicable(budgets, '2016-05-01').should.equal 750

    it 'should throw if validation fails', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500 }
        { startDate: '2016-05-01', endDate: '2016-05-31', amount: 'invalid' }
        { startDate: '2016-06-01', endDate: '2016-06-30', amount: 999 }
      ]
      try
        budget.validateAndFindApplicable(budgets, '2016-05-01')
      catch err
        err.should.have.property 'result'
        err.result.should.have.property 'valid'
        err.result.should.have.property 'errors'
        err.result.valid.should.equal false
        err.result.errors.should.not.be.empty

