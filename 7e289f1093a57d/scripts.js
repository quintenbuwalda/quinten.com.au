document.addEventListener('mousemove', function(e) {
    var sharpenElement = document.getElementById('sharpen');
    sharpenElement.style.left = e.pageX + 'px';
    sharpenElement.style.top = e.pageY + 'px';
});