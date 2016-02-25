assert = require 'assert'
chai = require 'chai'
expect = chai.expect
should = chai.should()
budget = require '../src/Budget'

describe 'budget', ->

  describe '#validate', ->

    it 'should check "budgets" is an array with at least 1 element', ->
      result = budget.validate undefined
      result.valid.should.equal false
      result.errors.should.be.deep.equal [
        parameter: 'budgets'
        message: 'Invalid budgets array specified.'
        value: undefined
      ]
      result = budget.validate null
      result.valid.should.equal false
      result.errors.should.be.deep.equal [
        parameter: 'budgets'
        message: 'Invalid budgets array specified.'
        value: null
      ]
      result = budget.validate []
      result.valid.should.equal false
      result.errors.should.be.deep.equal [
        parameter: 'budgets'
        message: 'Invalid budgets array specified.'
        value: []
      ]

    it 'should check amount property', ->
      result = budget.validate [
        { startDate: '2016-01-01', endDate: '2016-04-30' }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        parameter: 'amount'
        message: 'Required value.'
        value: undefined
      ]
      result = budget.validate [
        { amount: 'invalid', startDate: '2016-01-01', endDate: '2016-04-30' }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        parameter: 'amount'
        message: 'Incorrect type. Expected number.'
        value: 'invalid'
      ]
      result = budget.validate [
        { amount: 500, startDate: '2016-01-01', endDate: '2016-04-30' }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal true
      result.errors.should.be.an 'array'
      result.errors.should.be.empty

    it 'should check startDate property', ->
      result = budget.validate [
        { endDate: '2016-04-30', amount: 1 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        parameter: 'startDate'
        message: 'Required value.'
        value: undefined
      ]
      result = budget.validate [
        { startDate: 'not a moment', endDate: '2016-04-30', amount: 1 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        parameter: 'startDate'
        message: 'Invalid value. Value must be a moment.'
        value: 'not a moment'
      ]

    it 'should check endDate property', ->
      result = budget.validate [
        { startDate: '2016-01-01', amount: 750 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        parameter: 'endDate'
        message: 'Required value.'
        value: undefined
      ]
      result = budget.validate [
        { startDate: '2016-01-01', endDate: 'not a moment', amount: 1 }
      ]
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        parameter: 'endDate'
        message: 'Invalid value. Value must be a moment.'
        value: 'not a moment'
      ]

    it 'should check overlaps', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-01-02', amount: 1 }
        { startDate: '2016-01-02', endDate: '2016-01-03', amount: 1 }
      ]
      result = budget.validate budgets
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        message: 'Budget dates are overlapping.'
        parameter: 'budgets'
        value: budgets[0..1]
      ]
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-01-02', amount: 1 }
        { startDate: '2015-12-30', endDate: '2016-01-01', amount: 1 }
      ]
      result = budget.validate budgets
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        message: 'Budget dates are overlapping.'
        parameter: 'budgets'
        value: budgets[0..1]
      ]
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-01-03', amount: 1 }
        { startDate: '2016-01-02', endDate: '2016-01-02', amount: 1 }
      ]
      result = budget.validate budgets
      result.should.be.an 'object'
      result.should.have.property 'valid'
      result.should.have.property 'errors'
      result.valid.should.equal false
      result.errors.should.be.an 'array'
      result.errors.should.be.deep.equal [
        message: 'Budget dates are overlapping.'
        parameter: 'budgets'
        value: budgets[0..1]
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


