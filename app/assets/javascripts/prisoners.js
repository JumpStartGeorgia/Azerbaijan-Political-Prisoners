// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Add jQuery Select2 extra functionality to Charges multiple select
var addSelect2 = function() {
    $('select.charges_select').select2({
        placeholder: 'Select Charges',
        width: '110px'
    });

    $('select.tags_select').select2({
        placeholder: 'Select Tags',
        width: '300px'
    });
}

var addDatePickers = function() {
    $('.date_of_arrest_select, .date_of_release_select').datepicker({ dateFormat: 'yy-mm-dd'});
}

$(document).on('page:receive', function() {
    tinymce.remove();
});

$(document).ready(function() {
    if ($('body').hasClass('prisoners')) {
        addSelect2();
        loadTinymce();
        addDatePickers();

        $('#links').on('cocoon:after-insert', function(e, insertedItem) {
            addSelect2();
            loadTinymce();
            addDatePickers();
        });
    }
});
