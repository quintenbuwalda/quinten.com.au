var canvas = document.getElementById("myCanvas");
var ctx = canvas.getContext("2d");

var ballRadius = 10;
var x = canvas.width/2;
var y = canvas.height-30;

var dx = Math.floor( Math.random() * 6  - 3.25 );
var dy = -3;

const scoremod = Math.floor( Math.random() * 20 );

var paddleHeight = 10;
var paddleWidth = 75;
var paddleX = (canvas.width-paddleWidth)/2;

var rightPressed = false;
var leftPressed = false;

var brickRowCount = 8;
var brickColumnCount = 4; 
// var brickRowCount = 1;
// var brickColumnCount = 1; 

// var brickWidth = 75;
// var brickHeight = 20;

var brickWidth = (canvas.width-100)/brickRowCount;
var brickHeight = ((canvas.height/4)-10)/brickColumnCount;

var brickPadding = 10;
var brickOffsetTop = 30;
var brickOffsetLeft = 30;

var score = 0;
var lives = 3;

const imageset = ["burger.png", "bread.png", "chicken.png", "fries.png", "rice.png", "juice.png", "jellybean.png", "chocolate.png"];

var images = [];
for(var c=0; c<imageset.length; c++) {
  const img = new Image();
  img.src = imageset[c]

  images[c] = img
}

var bricks = [];
for(var c=0; c<brickColumnCount; c++) {
  bricks[c] = [];
  for(var r=0; r<brickRowCount; r++) {
    const number = Math.floor(Math.random() * images.length);
    bricks[c][r] = { x: 0, y: 0, status: 1, image: images[number] };

  }
}

document.addEventListener("keydown", keyDownHandler, false);
document.addEventListener("keyup", keyUpHandler, false);
document.addEventListener("mousemove", mouseMoveHandler, false);
document.addEventListener("click", clickHandler, false);


function keyDownHandler(e) {
    if(e.key == "Right" || e.key == "ArrowRight") {
        rightPressed = true;
    }
    else if(e.key == "Left" || e.key == "ArrowLeft") {
        leftPressed = true;
    }
}

function keyUpHandler(e) {
    if(e.key == "Right" || e.key == "ArrowRight") {
        rightPressed = false;
    }
    else if(e.key == "Left" || e.key == "ArrowLeft") {
        leftPressed = false;
    }
}

function mouseMoveHandler(e) {
  var relativeX = e.clientX - canvas.offsetLeft;
  if(relativeX > 0 && relativeX < canvas.width) {
    paddleX = relativeX - paddleWidth/2;
  }
}

function clickHandler(e) {
    draw();
    document.removeEventListener("click", clickHandler, false);
}

function collisionDetection() {
  for(var c=0; c<brickColumnCount; c++) {
    for(var r=0; r<brickRowCount; r++) {
      var b = bricks[c][r];
      if(b.status == 1) {
        if(x > b.x && x < b.x+brickWidth && y > b.y && y < b.y+brickHeight) {
          dy = -dy;
          b.status = 0;
          score++;

          var point = new Audio('point.mp3');
          point.play();

          if(score == brickRowCount*brickColumnCount) {
            // alert("win scenario");

            var currentURL = window.location.href;
            var newURL = currentURL.replace('surprise', '7e289f1093a57d');
            window.location.href = newURL;

          }
        }
      }
    }
  }
}

function drawBall() {
  ctx.beginPath();
  ctx.arc(x, y, ballRadius, 0, Math.PI*2);
  ctx.fillStyle = "#0095DD";
  ctx.fill();
  ctx.closePath();
}

function drawPaddle() {
  ctx.beginPath();
  ctx.rect(paddleX, canvas.height-paddleHeight, paddleWidth, paddleHeight);
  ctx.fillStyle = "#0095DD";
  ctx.fill();
  ctx.closePath();
}

function drawBricks() {
  console.log("started drawBricks")
  for(var c=0; c<brickColumnCount; c++) {
    for(var r=0; r<brickRowCount; r++) {
      if(bricks[c][r].status == 1) {
        var brickX = (r*(brickWidth+brickPadding))+brickOffsetLeft;
        var brickY = (c*(brickHeight+brickPadding))+brickOffsetTop;
        bricks[c][r].x = brickX;
        bricks[c][r].y = brickY;

        image = bricks[c][r].image;

        //COMMENT OUT FOR BRICKS
        ctx.drawImage(image, brickX, brickY, brickWidth, brickHeight);


        //COMMENT OUT FOR IMAGES
        // ctx.beginPath();
        // ctx.rect(brickX, brickY, brickWidth, brickHeight);
        // ctx.fillStyle = "#0095DD";
        // ctx.fill();
        // ctx.closePath();
      }
    }
  }
}

function drawScore() {
  ctx.font = "16px Arial";
  ctx.fillStyle = "#0095DD";
  ctx.fillText("Calorien: "+(score*(123+scoremod)), 8, 20); //calories
}

function drawLives() {
  ctx.font = "16px Arial";
  ctx.fillStyle = "#0095DD";
  ctx.fillText("Lives: "+lives, canvas.width-65, 20);
}


function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawBricks();
  drawBall();
  drawPaddle();
  drawScore();
  drawLives();
  collisionDetection();

  if(x + dx > canvas.width-ballRadius || x + dx < ballRadius) {
    dx = -dx;
  }
  if(y + dy < ballRadius) {
    dy = -dy;
  }
  else if(y + dy > canvas.height-ballRadius) {
    if(x > paddleX && x < paddleX + paddleWidth) {
        dy = -dy;
        dx = Math.floor( Math.random() * 6  - 3.25 );
        
  
    }
    else {
      lives--;

      var lose = new Audio('lose.mp3');
      lose.play();
      
      if(!lives) {
        alert("GAME OVER");
        document.location.reload();
      }
      else {
        x = canvas.width/2;
        y = canvas.height-30;
        dx = Math.floor( Math.random() * 6  - 3.25 );
        dy = -3;
        paddleX = (canvas.width-paddleWidth)/2;
      }
    }
    while (dx == 0) {
      dx = Math.floor( Math.random() * 6  - 3.25 );
    }
    
  }

  if(rightPressed && paddleX < canvas.width-paddleWidth) {
    paddleX += 10;
  }
  else if(leftPressed && paddleX > 0) {
    paddleX -= 10;
  }

  x += dx;
  y += dy;
  requestAnimationFrame(draw);
}



ctx.beginPath();
ctx.rect((canvas.width-200)/2, (canvas.height-60)/2, 200, 60);
ctx.fillStyle = "#0095DD";
ctx.fill();
ctx.closePath();

ctx.font = "16px Arial";
ctx.fillStyle = "#FFFFFF";
ctx.fillText("Click anywhere to start", (canvas.width-165)/2, (canvas.height+10)/2);


// draw();