_ = require 'lodash'
moment = require 'moment'

# moment throws a warning when bad dates are parsed
# As we're using moment for date validation, we avoid
# this warning to be print in our tests by doing this...
moment.createFromInputFallback = (config) ->
  config._d = new Date config._i

# default moment.isBetween() is exclusive, no option provided
inclusiveIsBetween = (x, a, b) ->
  x.isBetween(a, b) || x.isSame(a) || x.isSame(b)

# It's a shame lodash doesn't have something like this.
# lodash-contrib is talking about it:
# https://github.com/node4good/lodash-contrib/issues/47
combinations = (list) ->
  if list.length < 2 then return []
  first = _.first list
  tail  = _.tail list
  pairs = _.map tail, (x) -> return [first, x]
  return _.flatten [pairs, combinations(tail)], true

###
  A validation error.
  @property {string} parameter Invalid field name.
  @property {message} parameter Validation constraint message.
  @property {value} parameter Provided value.
###
class ValidationError
  constructor: (@parameter, @message, @value) ->

###
  Balihoo budget.
  @type {object} opts Budget properties.
###
class Budget

  constructor: (@opts) ->
    @errors = []

    if not @opts.amount
      @errors.push new ValidationError 'amount', 'Required value.', @opts.amount
    else if not (typeof @opts.amount == 'number')
      @errors.push new ValidationError 'amount', 'Incorrect type. Expected number.', @opts.amount

    if not @opts.startDate
      @errors.push new ValidationError 'startDate', 'Required value.', @opts.startDate
    else if not moment(@opts.startDate).isValid()
      @errors.push new ValidationError 'startDate', 'Invalid value. Value must be a moment.', @opts.startDate

    if not @opts.endDate
      @errors.push new ValidationError 'endDate', 'Required value.', @opts.endDate
    else if not moment(@opts.endDate).isValid()
      @errors.push new ValidationError 'endDate', 'Invalid value. Value must be a moment.', @opts.endDate

    if @errors.length is 0
      @amount = @opts.amount
      @start = moment @opts.startDate
      @end = moment @opts.endDate

###
  Budget validation result.
  @property {array} errors
            Errors found during validation process.
  @property {boolean} valid
            Indication whether validation was successful or not.
###
class ValidationResult

  constructor: ->
    @errors = []
    @valid = true

  addError: (error) ->
    @errors.push error
    @valid = false

###
  Holds budget related computations.
###
class BudgetUtil

  ###
    Validation all the specified budgets.
    @returns {ValidationResult} a validation result.
  ###
  @validate: (budgets) ->

    result = new ValidationResult

    if !budgets or !(budgets instanceof Array) or !(budgets.length > 0)
      result.addError new ValidationError 'budgets', 'Invalid budgets array specified.', budgets
    else
      # lift budget objects
      budgets = (new Budget b for b in budgets)

      # phase 1 - unitary validation
      for budget in budgets
        for error in budget.errors
          result.addError error

      if result.valid
        # phase 2 - date checks
        for combination in combinations(budgets)
          b1 = _.first combination
          b2 = _.last combination
          b1overlaps = inclusiveIsBetween(b1.start, b2.start, b2.end) or inclusiveIsBetween(b1.end, b2.start, b2.end)
          b2overlaps = inclusiveIsBetween(b2.start, b1.start, b1.end) or inclusiveIsBetween(b2.end, b1.start, b1.end)
          if b1overlaps or b2overlaps
            result.addError new ValidationError 'budgets', 'Budget dates are overlapping.', [ b1.opts, b2.opts ]

    return result

  ###
    @param {array} budgets
           Sequence of budget objects
    @param {?string} targetDate
           A date to find budget for.
    @return {number}
            A budget amount for the date, or null if no budget applicable for date.
  ###
  @findApplicable: (budgets, targetDate) ->
    targetDate = targetDate or moment().format('YYYY-MM-DD')
    for budget in budgets
      if targetDate >= budget.startDate and targetDate <= budget.endDate
        return budget.amount

module.exports = BudgetUtil

