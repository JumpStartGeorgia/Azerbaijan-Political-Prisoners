// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// When a new Type is selected, populate the Subtype select with that Type's Subtype children
$(document).ready(function() {
   $('#incidents').on('change', '.type_select', function( event ) {
       var type_id = $(event.target).val();
       console.log($(event.target).parent().next().children('select').children('option:selected').text());
   });
});

