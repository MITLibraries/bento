// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function TrackLinks( element ) {
  $( element ).click( function( e ) {
    fields = {
      hitType: 'event',
      eventCategory: 'Bento',
      eventAction: $( this ).parents( '.region' ).data( 'region' ),
      eventLabel: e.target.text
    };
    ga( 'send', fields );
  });
}
