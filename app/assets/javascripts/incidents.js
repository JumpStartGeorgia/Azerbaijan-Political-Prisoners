// Add jQuery Select2 extra functionality to Charges multiple select
function addSelect2() {
  $("select.charges_select").select2({
    placeholder: "Select Charges",
    width: "400px"
  });

  $("select.tags_select").select2({
    placeholder: "Select Tags",
    width: "400px"
  });
}

function addDatePickers() {
  $(".date_of_arrest_select, .date_of_release_select").datepicker({
    dateFormat: "yy-mm-dd",
    changeMonth: true,
    changeYear: true,
    yearRange: "-100:+0"
  });
}

$(document).ready(function() {
  if ($("form.incident").length) {
    addSelect2();
    loadTinymce();
    addDatePickers();
  }
});
