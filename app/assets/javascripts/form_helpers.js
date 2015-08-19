$(document).on('page:change', function() {
  if ($( "textarea.tinymce" ).length) {
    tinymce.remove();

    var tinymceOptions = {selector: "textarea.tinymce", height: 300};
    var tinymceDefaultConfig = gon.tinymce_config.default;

    // Add default config attributes to tinymce options
    for (var attrname in tinymceDefaultConfig) { tinymceOptions[attrname] = tinymceDefaultConfig[attrname]; }
    tinyMCE.init(tinymceOptions);
  }
});
