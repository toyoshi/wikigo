Dropzone.autoDiscover = false;

document.addEventListener("turbolinks:load", function() {
  //Only work at words form page
  if ($('#word_body').length == 0) { return; }

  //Dropzone.js
  var myDropzone;
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
          myDropzone = this;
      }
    });

  document.onpaste = function(event){
    var items = (event.clipboardData || event.originalEvent.clipboardData).items;
    for (index in items) {
      var item = items[index];
      if (item.kind === 'file') {
        myDropzone.addFile(item.getAsFile())
      }
    }
  }
});
