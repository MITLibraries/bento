function RealtimeStatus( id ) {
  var i = $(id);
  i.find('.realtime_status').each(function( index, an ) {
    var an_id = $( this ).data('an')
    var div_id = "#" + an_id;

    $.ajax({
      url: "/item_status?id=" + an_id
    }).done(function( msg ) {
      $(div_id).html( msg );
      $("#stale_locations_" + an_id).hide();
    }).fail(function( xhr, textStatus ) {
      console.log(xhr);
      $(div_id).html( 'Sorry, an error has occurred loading realtime availability information.' ).addClass('alert error');
    });
  });
}
