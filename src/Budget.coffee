validator = require 'node-validator'
S = require 'string'
moment = require 'moment'

DateValidatorParams =
  regex: /^\d{4}-\d{2}-\d{2}$/

Checks = validator.isObject()
  .withRequired 'amount', validator.isNumber()
  .withRequired 'startDate', validator.isString(DateValidatorParams)
  .withRequired 'endDate', validator.isString(DateValidatorParams)

###
  Result of budgets validation.
  @property {array} errors
            An array of validation errors.
  @property {boolean} valid
            Indicates whether errors were found or not.
###
class ValidationResult
  constructor: (@errors) ->
    @valid = @errors.length is 0

###
  Error thrown when budgets dates overlaps.
  @property {string} date1
            First date in error.
  @property {string} date2
            Second date in error.
  @property {string} message
            A message to explain the error.
###
class OverlappingDatesError extends Error
  constructor: (paddedDate1, paddedDate2) ->
    @date1 = S(paddedDate1).chompRight('E').chompRight('S').s
    @date2 = S(paddedDate2).chompRight('E').chompRight('S').s
    msg1 = if S(paddedDate1).endsWith('S') then "#{@date1} (startDate)" else "#{@date1} (endDate)"
    msg2 = if S(paddedDate2).endsWith('S') then "#{@date2} (startDate)" else "#{@date2} (endDate)"
    @message = "Overlapping dates in budgets: #{msg1} overlaps with #{msg2}"

###
  Error thrown when budgets are invalid.
  @property {ValidationResult} result
###
class InvalidBudgetsError extends Error
  constructor: (@result) ->

###
  Finds overlapping budget dates and throw an exception
  on the first encountered occurence.
  @params {array} budgets
          An array of budget object.
###
checkOverlappingDates = (budgets) ->
  paddedDates = []
  for budget in budgets
    paddedDates.push budget.startDate + 'S'
    paddedDates.push budget.endDate + 'E'
  paddedDates.sort()
  previousDate = paddedDates[0]
  for currentDate in paddedDates[1..]
    date1 = S(previousDate).chompRight('E').chompRight('S').s
    date2 = S(currentDate).chompRight('E').chompRight('S').s
    if date1 == date2
      throw new OverlappingDatesError previousDate, currentDate
    if S(previousDate).endsWith('S') and S(currentDate).endsWith('S')
      throw new OverlappingDatesError previousDate, currentDate
    previousDate = currentDate

###
  Validation all the specified budgets.
  @returns {ValidationResult} a validation result.
###
validate = (budgets) ->
  errors = []

  # phase 1: basic property validation
  for budget in budgets
    validator.run Checks, budget, (errorCount, errs) ->
      errors.push err for err in errs

  if errors.length is 0
    # phase 2: date checks
    try
      checkOverlappingDates budgets
    catch err
      if err instanceof OverlappingDatesError
        errors.push
          message: err.message
      else
        throw err

  new ValidationResult errors

###
  @param {array} budgets
         An array of budget object.
  @param {string} targetDate
         A date to find budget for.
  @return {number}
          A budget amount for the date, or null if no budget applicable for date.
###
findApplicable = (budgets, targetDate) ->
  targetDate = targetDate or moment().format('YYYY-MM-DD')
  for budget in budgets
    if targetDate >= budget.startDate and targetDate <= budget.endDate
      return budget.amount

###
  @param {array} budgets
         An array of budget object.
  @param {string} targetDate
         A date to find budget for.
  @return {number}
          A budget amount for the date.
  @throws {InvalidBudgetsError}
          If the budgets are not valid.
###
validateAndFindApplicable = (budgets, targetDate) ->
  validationResult = validate budgets
  if validationResult.valid
    return findApplicable budgets, targetDate
  else
    throw new InvalidBudgetsError validationResult

class Budget
  @validate: validate
  @findApplicable: findApplicable
  @validateAndFindApplicable: validateAndFindApplicable

module.exports = Budget

