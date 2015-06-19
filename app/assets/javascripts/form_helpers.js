function loadTinymce() {
  if ($( "textarea.tinymce" ).length) {
    var tinymceOptions = {selector: "textarea.tinymce", height: 300};
    var tinymceDefaultConfig = gon.tinymce_config.default;

    // Add default config attributes to tinymce options
    for (var attrname in tinymceDefaultConfig) { tinymceOptions[attrname] = tinymceDefaultConfig[attrname]; }
    tinyMCE.init(tinymceOptions);
  }
}
