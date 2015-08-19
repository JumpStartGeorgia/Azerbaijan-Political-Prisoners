// Add jQuery Select2 extra functionality to Charges multiple select
function addSelect2() {
  addSelect2Translations();

  $("select.charges_select").select2({
    placeholder: gon.select_charges,
    width: "400px"
  });

  $("select.tags_select").select2({
    placeholder: gon.select_tags,
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
