module.exports = class ValidationError
  constructor: (@parameter, @message, @value) ->
