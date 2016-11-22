document.addEventListener("turbolinks:load", function() {
  //Only work at words form page
  if ($('#word_body').length == 0) { return; }

  //For stop init editor twice
  if ($('#turbolinks-permanent-simplemde').length > 0) { return; }
  $('body').append('<div id="turbolinks-permanent-simplemde">');

  //Simple mde
  simplemde = new SimpleMDE({ 
    element: $('#word_body')[0],
    spellChecker: false
  });

  var unsaved = false;
  var formWarningMessage = 'Are you sure?';
  simplemde.codemirror.on("change", function(){
    unsaved = true; 
  });

  $('a').click(function(e){
    var href = $(this).attr('href')
    if(typeof(href) !== "undefined" && href != '#' && unsaved){
      if(confirm(formWarningMessage) == false){
        e.preventDefault()
      }
    }
  });

  $(window).on('beforeunload', function(){
    if(unsaved){
      return formWarningMessage
    }
  });

  $('input[type=submit]').on('click', function(e) { 
    $(window).off('beforeunload'); 
  }); 
});
