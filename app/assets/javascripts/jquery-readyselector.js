// Explanation of usage: http://brandonhilkert.com/blog/page-specific-javascript-in-rails/
// Source code: https://github.com/Verba/jquery-readyselector/blob/master/jquery.readyselector.js

(function ($) {
    var ready = $.fn.ready;
    $.fn.ready = function (fn) {
        if (this.context === undefined) {
            // The $().ready(fn) case.
            ready(fn);
        } else if (this.selector) {
            ready($.proxy(function(){
                $(this.selector, this.context).each(fn);
            }, this));
        } else {
            ready($.proxy(function(){
                $(this).each(fn);
            }, this));
        }
    }
})(jQuery);