
for (var i = 0; i < 50 ; i++) {
    var element = document.createElement('img');
    element.src = "soup.png";
    document.body.appendChild(element);
}

function randomPosition() {
    var images = document.querySelectorAll("img");
    for (var i = 0; i < images.length; i++) {
        var x = Math.random() * (window.innerWidth - images[i].clientWidth-50);
        var y = Math.random() * (window.innerHeight - images[i].clientHeight-50);
        var width = images[i].clientWidth;
        var height = images[i].clientHeight;

        // Set the position and rotation of the image.
        images[i].style.top = y + "px";
        images[i].style.left = x + "px";
        images[i].style.transform = "rotate(" + Math.random() * 360 + "deg)";
    }
}


// TURN ON FOR LOADING
window.onload = randomPosition;




// function randomPosition() {
//     var images = document.querySelectorAll("img");
//     for (var i = 0; i < images.length; i++) {
//       var x = Math.random() * window.innerWidth;
//       var y = Math.random() * window.innerHeight;
//       var width = images[i].clientWidth;
//       var height = images[i].clientHeight;
  
//       // Make sure the image is within the bounds of the screen.
//       x = Math.max(0, x - width / 2);
//       x = Math.min(window.innerWidth, x + width / 2);
//       y = Math.max(0, y - height / 2);
//       y = Math.min(window.innerHeight, y + height / 2);
  
//       // Set the position and rotation of the image.
//       images[i].style.top = y + "px";
//       images[i].style.left = x + "px";
//       images[i].style.transform = "rotate(" + Math.random() * 360 + "deg)";
//     }
//   }