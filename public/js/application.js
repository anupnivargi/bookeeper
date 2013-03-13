$(document).ready(function(){

  $("#entry-isbn").focus();

  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });

  $("#entry-isbn").keyup(function(){
    if(($(this).val().length == 10) || ($(this).val().length == 13)){
      var url = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + $(this).val();
      $.ajax({ 
        url : url,
        dataType: "json",
        success: function(data, textStatus, xhr){
          var totalItems = data.totalItems;
          if(totalItems > 0){
            var items = data.items;
            var item = items[0];
            console.log(item);
            var volumeInfo = item.volumeInfo;
            var title = volumeInfo.title;
            var subtitle = volumeInfo.subtitle;
            if(subtitle){
              $("#entry-name").val(title + ":" + subtitle);
            }else{
              $("#entry-name").val(title);
            }
            $("#entry-form").submit();
          }else{
            alert("No match found");
            $("#entry-isbn").val("");
          }
        }
      });
    }

  }); 
});

