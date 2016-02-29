_ = require 'lodash'
moment = require 'moment'
ValidationError = require './ValidationError'

# default moment.isBetween() is exclusive, no option provided
inclusiveIsBetween = (someDate, startDate, endDate) ->
  start = startDate.startOf 'day'
  end = endDate.endOf 'day'
  someDate.isBetween(start, end) or someDate.isSame(start) or someDate.isSame(end)

module.exports = class Budget
  constructor: (@amount, @startDate, @endDate) ->
    @errors = []
    @originalData = { @amount, @startDate, @endDate }

    if not @amount
      @errors.push new ValidationError 'amount', 'Required value.', @amount
    else if not (typeof @amount == 'number')
      @errors.push new ValidationError 'amount', 'Incorrect type. Expected number.', @amount

    if not @startDate
      @errors.push new ValidationError 'startDate', 'Required value.', @startDate
    else if not moment(@startDate).isValid()
      @errors.push new ValidationError 'startDate', 'Invalid value. Value must be a moment.', @startDate
    else
      @startDate = moment @startDate

    if not @endDate
      @errors.push new ValidationError 'endDate', 'Required value.', @endDate
    else if not moment(@endDate).isValid()
      @errors.push new ValidationError 'endDate', 'Invalid value. Value must be a moment.', @endDate
    else
      @endDate = moment @endDate

  isValid: -> @errors.length is 0

  overlaps: (budget) ->
    if not budget instanceof Budget
      throw new Error '"budget" must be a Budget instance.'
    inclusiveIsBetween(@startDate, budget.startDate, budget.endDate) or
    inclusiveIsBetween(@endDate, budget.startDate, budget.endDate) or
    inclusiveIsBetween(budget.startDate, @startDate, @endDate) or
    inclusiveIsBetween(budget.endDate, @startDate, @endDate)

  isApplicable: (someDate) ->
    if not (someDate instanceof moment)
      throw new Error '"someDate" must be a moment!'
    if not @isValid()
      throw new Error 'Invalid budget, cannot check applicability!'
    inclusiveIsBetween someDate, @startDate, @endDate
