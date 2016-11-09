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

function ReportSummary( category, count ) {
  count = ( typeof count !== 'undefined' ) ? count : 0;
  $( '.results-summary .results-summary-item[data-region="' + category + '"] .count' ).html( count );
}
