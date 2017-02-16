// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function TrackLinks( element ) {
  $( element ).click( function( e ) {
    // If the element is contained within an element with a "region" class and a valid data attribute, use that.
    // If not, use the placeholder "Link".
    action = $( this ).parents( '.region' ).data( 'region' ) ? $( this ).parents( '.region' ).data( 'region' ) : 'Link';

    // If the element has a data attribute for "type", use that. if not, use the text of the element.
    label = e.currentTarget.dataset.type ? e.currentTarget.dataset.type : e.currentTarget.text.trim();

    fields = {
      hitType: 'event',
      eventCategory: 'Bento',
      eventAction: action,
      eventLabel: label
    };

    ga( 'send', fields );
  });
}

function ReportSummary( category, count ) {
  count = ( typeof count !== 'undefined' ) ? count : 0;
  $( '.results-summary .results-summary-item[data-region="' + category + '"] .count' ).html( count );
}
