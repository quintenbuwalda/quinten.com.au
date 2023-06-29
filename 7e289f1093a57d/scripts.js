document.addEventListener('mousemove', function(e) {
    var sharpenElement = document.getElementById('sharpen');
    sharpenElement.style.left = e.pageX + 'px';
    sharpenElement.style.top = e.pageY + 'px';
});

const svg = document.querySelector("svg");
const svgStyles = getComputedStyle(svg);
const w = Number(svgStyles.width.split("px")[0]);
const h = Number(svgStyles.height.split("px")[0]);

const randRange = (min, max) => Math.random() * (max - min) + min;

for (i = 0; i < (w + h) / 10; i++) {
	const circle = document.createElementNS(
		"http://www.w3.org/2000/svg",
		"circle"
	);

	const r = randRange(20, 60);

	circle.setAttribute("r", r);
	circle.setAttribute("cx", Math.round(Math.random() * w));
	circle.setAttribute("cy", Math.round(Math.random() * h));

	const fill = "none";
	circle.setAttribute("fill", fill);

	const stroke = `hsl(${randRange(0, 360)}deg 40% 80%)`;
	circle.setAttribute("stroke", stroke);

	const strokeWidth = r / 10;
	circle.setAttribute("stroke-width", strokeWidth);

	circle.setAttribute(
		"style",
		`stroke-dasharray: ${r * 0.5}, ${r * Math.PI * 2 - r * 0.5};
		stroke-dashoffset: ${r * Math.PI * 2};
		--radius: ${r};
		--duration: ${randRange(3, 5)}s;
		--delay: ${randRange(-1, 1)}s; 
		--direction: ${i % 2 === 0 ? "reverse" : "normal"}`
	);

	svg.appendChild(circle);
}
