// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// When a new Type is selected, populate the Subtype select with that Type's Subtypes
var populateSubtypes = function() {
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
}

// Add jQuery Select2 extra functionality to Charges multiple select
var addSelect2 = function() {
    $('select.charges_select').select2({
        placeholder: 'Select Charges',
        width: '110px'
    });
}

var loadTinymce = function() {
    var tinymceOptions = {selector: "textarea.tinymce"};
    var tinymceDefaultConfig = gon.tinymce_config.default;

    // Add default config attributes to tinymce options
    for (var attrname in tinymceDefaultConfig) { tinymceOptions[attrname] = tinymceDefaultConfig[attrname]; }

    tinyMCE.init(tinymceOptions);
}

var initialAndCocoonCode = function() {
    addSelect2();
    loadTinymce();
}

var ready = function() {
    populateSubtypes();
    initialAndCocoonCode();

    $('#links').on('cocoon:after-insert', function(e, insertedItem) {
        initialAndCocoonCode();
    });
}

$(document).on('page:load', ready);
$(document).ready(ready);

