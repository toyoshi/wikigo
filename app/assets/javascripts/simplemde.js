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
});
