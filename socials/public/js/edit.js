// var picture = $('#thepicture');  // Must be already loaded or cached!
// picture.guillotine({width: 400, height: 300});


// Example POST method implementation:
async function postData(url = '', data = {}) {
    // Default options are marked with *
    const response = await fetch(url, {
      method: 'POST', // *GET, POST, PUT, DELETE, etc.
      mode: 'cors', // no-cors, *cors, same-origin
      cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
      credentials: 'same-origin', // include, *same-origin, omit
      headers: {
        'Content-Type': 'application/json'
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      redirect: 'follow', // manual, *follow, error
      referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
      body: JSON.stringify(data) // body data type must match "Content-Type" header
    });
    return response.json(); // parses JSON response into native JavaScript objects
  }


    var picture = $('#thepicture')
  
    var camelize = function() {
      var regex = /[\W_]+(.)/g
      var replacer = function (match, submatch) { return submatch.toUpperCase() }
      return function (str) { return str.replace(regex, replacer) }
    }()
  
    var showData = function (data) {
      data.scale = parseFloat(data.scale.toFixed(4))
      for(var k in data) { $('#'+k).html(data[k]) }
    }
  
    picture.on('load', function() {
      picture.guillotine({ eventOnChange: 'guillotinechange' })
      picture.guillotine('fit')
      for (var i=0; i<5; i++) { picture.guillotine('zoomIn') }
  
      // Show controls and data
      $('.loading').remove()
      $('.notice, #controls, #data').removeClass('hidden')
      showData( picture.guillotine('getData') )
  
      // Bind actions
      $('#controls a').click(function(e) {
        e.preventDefault()
        action = camelize(this.id)
        picture.guillotine(action)
      })
  
      // Update data on change
      picture.on('guillotinechange', function(e, data, action) { showData(data) })
    })

    
   
  
    function resizeImage(url, width, height, x, y, callback) {
        var canvas = document.createElement("canvas");
        var context = canvas.getContext('2d');
        var imageObj = new Image();
    
        // set canvas dimensions
    
        canvas.width = width;
        canvas.height = height;
    
        imageObj.onload = function () {
            context.drawImage(imageObj, x, y, width, height, 0, 0, width, height);
            callback(canvas.toDataURL());
            // canvas.toBlob((d)  => {
            //     callback(d);
            //     var data = new FormData();
            //     // data.append("record[video]", recorder.getBlob(), (new Date()).getTime() + ".webm");

            //     // postData("/media/edit", d);
            // })
            
        };
        // https://stackoverflow.com/questions/34111390/displaying-blob-image-from-mysql-database-into-dynamic-div-in-html
    
        imageObj.src = url;
        var testdiv = document.getElementById("newImg");
        console.log(testdiv);
        document.getElementById("newImg").appendChild(canvas);
        

    }   
// https://stackoverflow.com/questions/36071562/crop-image-with-x-y-coordinates-in-javascript/36072741


function getTheData(pic)
{
    console.log(pic);
    data = picture.guillotine('getData');
    console.log(data);
    resizeImage(pic, 100,100,0,0, (databack) => {
            console.log(databack);
    })
}