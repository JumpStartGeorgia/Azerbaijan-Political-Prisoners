# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

## When a new Type is selected, populate the Subtype select with that Type's Subtype children
$(document).ready(() ->
  $('.type_select').change(() ->
    console.log('Selected: ' + $('#prisoner_incidents_attributes_0_type_id option:selected').text())
    return
  )
  return
)


