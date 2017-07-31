_ = require 'lodash'
assert = require 'assert'
chai = require 'chai'
expect = chai.expect
should = chai.should()
BudgetUtil = require '../src/BudgetUtil'

describe 'budget lib', ->

  describe '#validate', ->

    it 'should check "budgets" is an array with at least 1 element', ->
      result = BudgetUtil.validate undefined
      expect(result).to.be.defined
      result.valid.should.equal false
      result.errors.should.be.deep.equal [
        parameter: 'budgets'
        message: 'Invalid budgets array specified.'
        value: undefined
      ]
      result = BudgetUtil.validate null
      expect(result).to.be.defined
      result.valid.should.equal false
      result.errors.should.be.deep.equal [
        parameter: 'budgets'
        message: 'Invalid budgets array specified.'
        value: null
      ]
      result = BudgetUtil.validate []
      expect(result).to.be.defined
      result.valid.should.equal false
      result.errors.should.be.deep.equal [
        parameter: 'budgets'
        message: 'Invalid budgets array specified.'
        value: []
      ]

    it 'should check budget individually', ->
      budgets = [
        { startDate: '2016-01-01', endDate: 'invalid', amount: 1 }
      ]
      result = BudgetUtil.validate budgets
      result.should.have.property 'errors'
      result.errors.should.be.deep.equal [
        message: 'Invalid value. Value must be a moment.'
        parameter: 'endDate'
        value: 'invalid'
      ]

    it 'should check budgets overlapping', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-01-30', amount: 1 }
        { startDate: '2016-01-02', endDate: '2016-01-03', amount: 1 }
      ]
      result = BudgetUtil.validate budgets
      result.should.have.property 'errors'
      result.errors.should.be.deep.equal [
        message: 'Budget dates are overlapping.'
        parameter: 'budgets'
        value: budgets
      ]

  describe '#findApplicable', ->

    it 'should throw an error if specified date is not a moment', ->
      call = BudgetUtil.findApplicable.bind(BudgetUtil, 'invalid')
      expect(call).to.throw Error

    it 'should return undefined if no budget for specified date', ->
      b = BudgetUtil.findApplicable [], '2016-01-01'
      expect(b).to.equal undefined

    it 'should return budget for specified date', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2016-04-30', amount: 500, shared: {'stuff': 20, 'things': 80} }
        { startDate: '2016-05-01', endDate: '2016-07-30', amount: 400 }
      ]
      b = BudgetUtil.findApplicable budgets, '2016-04-30T00:05:00Z'
      console.log b
      expect(b).to.deep.equal _.head(budgets)

    it 'should use today\'s date if date not provided', ->
      budgets = [
        { startDate: '2016-01-01', endDate: '2116-01-01', amount: 500 }
      ]
      b = BudgetUtil.findApplicable budgets
      expect(b).to.deep.equal _.head(budgets)
