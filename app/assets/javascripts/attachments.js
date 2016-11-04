$(document).on('turbolinks:load ready', function() {
  if ($('#word_body').length == 0 || $('form.dz-clickable').length > 0) { return; }

  simplemde = new SimpleMDE({ 
    element: $('#word_body')[0],
    spellChecker: false
  });

  Dropzone.autoDiscover = false;
  var de =  $("#upload-dropzone");
  de.dropzone(
    {
      url: de.attr('url'),
      paramName: 'attachment[file]',
      previewTemplate: '<div style="display:none"></div>',
      init: function(){
          this.on('sending', function(file, xhr, formData){
            formData.append('authenticity_token', de.attr('authenticity-token'));
          }),
          this.on('addedfile', function(file, json) {
            console.log(file);
            simplemde.codemirror.replaceSelection("<!-- Uploading " + file.name + " -->")
          }),
          this.on('success', function(file, json) {
            var code = "![" + json.file.url + "](" + json.file.url + ")"
            var text = simplemde.value();
            simplemde.value(text.replace("<!-- Uploading " + file.name + " -->", code));
          });
      }
    });
});
