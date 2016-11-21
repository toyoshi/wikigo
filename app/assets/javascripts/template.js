document.addEventListener("turbolinks:load", function() {
  //Only work at words form page
  if ($('#template-selector').length == 0) { return; }

  $('#template-selector').change(function(){
    var selected_text = $('option:selected', $(this)).text();
    if(selected_text.length == 0) { return; }

    if(simplemde.value().length > 0) {
      if(!window.confirm('Are you sure?')) {
        return false;
      }
    }

    $('#word_title').val(selected_text);
    simplemde.value($(this).val());
  });
});
