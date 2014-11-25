// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var ready = function() {
    // When a new Type is selected, populate the Subtype select with that Type's Subtypes
    $('#incidents').on('change', '.type_select', function( event ) {
        var new_type_id = $(event.target).val();
        var subtype_select = $(event.target).parent().next().children('select');

        // Remove subtype select options
        subtype_select.find('option').remove();

        // Add subtypes of new type to subtype select options
        $.each(gon.subtype_map, function( index, value) {
            if (parseInt(new_type_id) === value.type_id ) {
                subtype_select.append('<option value="' + value.id + '">' + value.name + '</option>')
            }
        });
    });

    $('#prisoner_incidents_attributes_0_charges').select2({
        placeholder: 'Select Charges',
        width: '110px'
    });
}

$(document).on('page:load', ready);
$(document).ready(ready);