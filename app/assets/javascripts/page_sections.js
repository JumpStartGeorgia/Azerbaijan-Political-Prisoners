$(document).on('page:change', function() {
  if ($('form.page_section').length) {
    loadTinymce();
  }
});
