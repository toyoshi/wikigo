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

    $('#word_title').val(replace_template_variables(selected_text));
    simplemde.value($(this).val());
  });

  function replace_template_variables(str){
    var date = new Date();
    var yyyy = date.getFullYear();
    var mm = ("0"+date.getMonth() + 1).slice(-2);
    var dd = ("0"+date.getDate()).slice(-2);
    str = str.replace(/\$\{Year\}/g, yyyy);
    str = str.replace(/\$\{month\}/g, mm);
    str = str.replace(/\$\{day\}/g, dd);
    return str;
  }
});

