// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// When a new Type is selected, populate the Subtype select with that Type's Subtypes
$(document).ready(function() {
    $('#incidents').on('change', '.type_select', function( event ) {
        var new_type_id = $(event.target).val();
        var subtype_select = $(event.target).parent().next().children('select');

        // Remove subtype select options
        subtype_select.find('option').remove();

        // Add subtypes of new type to subtype select options

    });
});

