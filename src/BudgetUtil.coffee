_ = require 'lodash'
moment = require 'moment'
Budget = require './Budget'
ValidationError = require './ValidationError'

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
  Validates all budgets in the specified list.
  @api public
  @param {Budget[]} budgets - A list of budgets to validate.
  @returns {ValidationResult} Budget validation result.
###
module.exports.validate = (budgets) ->
  ###
    h3 Example:
      var BudgetUtil = require('balihoo-budget-lib');
      var myBudgets = [
        {
            "amount": 500,
            "startDate": "2016-01-01",
            "endDate": "2016-04-30"
        }
      ];
      var validation = BudgetUtil.validate(myBudgets);
      if (validation.valid === true) {
        // deal with valid budgets!
      }
  ###
  -> # hack: terminate jsdoc above

  result = new ValidationResult
  if !budgets or !(budgets instanceof Array) or !(budgets.length > 0)
    result.addError new ValidationError 'budgets', 'Invalid budgets array specified.', budgets
  else
    # lift budget objects
    budgets = (new Budget(b.amount, b.startDate, b.endDate, b.shared) for b in budgets)

    # phase 1 - unitary validation
    for budget in budgets
      for error in budget.errors
        result.addError error

    if result.valid
      # phase 2 - date checks
      for combination in combinations(budgets)
        b1 = _.first combination
        b2 = _.last combination
        if b1.overlaps b2
          originals = [ b1.originalData, b2.originalData ]
          result.addError new ValidationError 'budgets', 'Budget dates are overlapping.', originals
  result

###
  Finds the applicable budget amount within the given budgets.
  @api public
  @param {Budget[]} budgets - A list of valid budget objects.
  @param {String} targetDate - A MomentJS compatible date string.
  @returns {Number} The applicable budget amount for the specified date.
###
module.exports.findApplicable = (budgets, targetDate = moment.utc()) ->
  ###
  h3 Examples
    var BudgetUtil = require('balihoo-budget-lib');
    var myBudgets = [
      {
          "amount": 500,
          "startDate": "2016-01-01",
          "endDate": "2016-04-30"
      }
    ];
    // "myBudgets" should be validated at this point
    var budget = BudgetUtil.findApplicable(myBudgets, '2016-02-18');
    // deal with budget...
  ###
  -> # hack: terminate jsdoc above

  if not moment.isMoment targetDate
    targetDate = moment.utc targetDate
    if not targetDate.isValid()
      throw new Error 'Invalid target date provided.'

  for budget in budgets
    b = new Budget budget.amount, budget.startDate, budget.endDate, budget.shared
    if b.isApplicable targetDate then return budget

###
  @class Budget
  @property {Number} amount - Available amount of money for the budget period.
  @property {String} startDate - MomentJS-compatible date for budget period start.
  @property {String} endDate - MomentJS-compatible date for budget period end.
###
b = ->

###
  @class ValidationResult
  @property {ValidationError[]} errors - Details for all validation errors.
  @property {Boolean} valid - Whether all budgets are valid or not.
###
class ValidationResult
  constructor: ->
    @errors = []
    @valid = true

  addError: (error) ->
    @errors.push error
    @valid = false

###
  @class ValidationError
  @property {String} parameter - Name of bad property.
  @property {String} message - Details about the failed validation.
  @property {String} value - Provided value.
###
ve = ->
