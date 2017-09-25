function Toggler(){
  var b = $(".expand-collapse-wrap .button"); // set up all expand buttons
  var w = $(".expand-collapse-wrap"); // close all expand wraps

  w.height(100); // customize how much to show

  b.click(function() {

    var tb = $(this); // this button
    var te = tb.parent().next(".expand-container"); // this div to expand
    var tw = tb.closest(".expand-collapse-wrap"); // this wrap div

    if(tw.hasClass('is-expanded')) {
      tw.removeClass('is-expanded');
      tw.height(100);
      tb.html('Show more');
    } else {
      tw.addClass('is-expanded');
      tw.height(te.outerHeight(true));
      tb.html('Show less');
    }

  });
}
