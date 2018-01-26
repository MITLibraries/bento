// from style guide - last updated 1/22/2018 - commit 271b76d 
function Toggler() {
  // set up all expand buttons
  var b = $( '.expand-collapse-wrap .button' );
  
  // find and set height for collapse wraps
  $( '.expand-collapse-wrap' ).each (function( index, element ) {
    var xheight = $( element ).data( 'xheight' );
    $( element ).height( xheight );
  });

  b.click(function( xheight ) {

    var tb = $( this ); // this button
    var te = tb.parent().next( '.expand-container' ); // this div to expand
    var tw = tb.closest( '.expand-collapse-wrap' ); // this wrap div
    var txheight = tw.data( 'xheight' ); // this collapsed height

    if(tw.hasClass( 'is-expanded' )) {
      tw.removeClass( 'is-expanded' );
      tw.height( txheight );
      tb.html( 'Show more' );
    } else {
      tw.addClass( 'is-expanded' );
      tw.height( te.outerHeight( true ) );
      tb.html( 'Show less' );
    }
  });
}

