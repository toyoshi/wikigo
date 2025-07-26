document.addEventListener("turbolinks:load", function() {
  //Only work at words form page
  if ($('#word_tag_list').length == 0) { return; }

  $('#word_tag_list').tagit({
    availableTags: gon.all_tag_list
  });
});
