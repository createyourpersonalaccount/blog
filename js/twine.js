/* TODO:
  1. Study
  <https://brennaobrien.com/blog/2014/05/style-input-type-range-in-every-browser.html>
  for help with the slider appearance.
  2. Replace draw() method with draw-if-needed. (look into redraw().)
*/
let shapes = ["circle", "square"];
let canvasWidth = 500;
let canvasHeight = 500;
let numberOfPoints;
let numberOfPointsLabel;
let shapeSelection;
let twineLabel;
let twine;
let repeatLabel;
let repeat;

function setup() {
    /* number of points slider */
    numberOfPointsLabel = createDiv('Number of pegs ');
    numberOfPoints = createSlider(2, 36, 17, 1);
    numberOfPoints.parent(numberOfPointsLabel);
    numberOfPoints.style('width', '160px');
    console.log(numberOfPoints.size()); // TODO use .size() to set slider size.

    /* convex shape selection */
    shapeSelectionLabel = createDiv('Shape ');
    shapeSelection = createSelect();
    shapeSelection.parent(shapeSelectionLabel)
    for(let i = 0; i < shapes.length; i++) {
        shapeSelection.option(shapes[i]);
    }
    shapeSelection.selected(shapes[0]);

    /* twine input */
    twineLabel = createDiv('Twine ');
    twine = createInput('');
    twine.parent(twineLabel);

    repeatLabel = createDiv('Repeat ');
    repeat = createInput('');
    repeat.parent(repeatLabel);

    /* convex shape selection */
    twineColorLabel = createDiv('Color ');
    // use twineColor.color() to get value and .input() for callback
    twineColor = createColorPicker('#ff0000');
    twineColor.parent(twineColorLabel)
    
    /* draw the empty canvas */
    createCanvas(canvasWidth, canvasHeight);
}

function draw() {
    /* Clear the drawing with grey */
    background(220);
    let pegs = numberOfPoints.value();
    /* Display the number of pegs */
    textSize(32);
    text(pegs, 10, 40);
    /* Act according to chosen shape */
    switch(shapeSelection.value()) {
    case 'circle':
        drawCircle(pegs);
        break;
    case 'square':
        drawSquare(pegs);
        break;
    default:
        /* should not happen */
        console.error('The chosen value is not one of the programmed shapeSelection values.');
        break;
    }
}

function pegCoordinates(pegIndex, numberOfPegs, radius) {
    let angle = Math.PI/2 - 2*Math.PI*pegIndex / numberOfPegs; // like a clock
    return [canvasWidth / 2 + (radius + 10)*Math.cos(angle),
            canvasHeight / 2 - (radius + 10)*Math.sin(angle)];
            
}

function pegTextCoordinates(pegIndex, numberOfPegs, radius) {
    let angle = Math.PI/2 - 2*Math.PI*pegIndex / numberOfPegs; // like a clock
    let pad = 0;
    if(Math.cos(angle) < 0.2 && Math.sin(angle) < 0)
        pad = 10;
    return [canvasWidth / 2 + (radius + 24 + pad)*Math.cos(angle),
            canvasHeight / 2 - (radius + 24 + pad)*Math.sin(angle)];
            
}

function drawCircle(pegs) {
    let radius = Math.sqrt(canvasWidth*canvasWidth + canvasHeight*canvasHeight) / Math.sqrt(3) / 2;
    circle(canvasWidth / 2 ,canvasHeight / 2, 2*radius);
    for(let i = 0; i < pegs; i++) {
        let [x, y] = pegCoordinates(i + 1, pegs, radius);
        drawPeg(x, y);
        let [z, w] = pegTextCoordinates(i + 1, pegs, radius);
        textSize(16);
        text(i + 1, z, w);
    }
    push();
    strokeWeight(2);
    stroke(twineColor.color());
    let lines = parseLines(pegs, twine.value());
    lines.map(pair => {
        let [i, j] = pair;
        let [x1, y1] = pegCoordinates(i, pegs, radius);
        let [x2, y2] = pegCoordinates(j, pegs, radius);
        line(x1, y1, x2, y2);
    });
    if(lines.length > 0) {
        let guide = lines[0][0];
        let repeatIndices = parsePegIndices(pegs, repeat.value());
        for(let i = 0; i < repeatIndices.length; i++) {
            let repeat = repeatIndices[i];
            let shift = lines.map(pair => {
                let [i, j] = pair;
                return [(i + (repeat - guide)) % pegs,
                        (j + (repeat - guide)) % pegs];
            });
            shift.map(pair => {
                let [i, j] = pair;
                let [x1, y1] = pegCoordinates(i, pegs, radius);
                let [x2, y2] = pegCoordinates(j, pegs, radius);
                line(x1, y1, x2, y2);
            });
        }
    }
    pop();
}

function drawSquare(pegs) {
    let side = Math.sqrt(canvasWidth*canvasWidth + canvasHeight*canvasHeight) / Math.sqrt(3);
    square(canvasWidth / 2 - side / 2, canvasHeight / 2 - side / 2, side);
    for(let i = 0; i < pegs; i++) {
        let angle = Math.PI/2 - 2*Math.PI*i / pegs; // like a clock
        /* We add 0.001 to detect corners without getting into
           floating-point equality issues; this is fine since numberOfPoints
           is capped.  */
        if(Math.abs(Math.cos(angle)) > 1/sqrt(2) + 0.001) {
            /* These are the left/right sides */
            let x = Math.sign(Math.cos(angle)) * (side / 2 + 10);
            let y = Math.sign(Math.cos(angle)) * (side / 2) * Math.tan(angle);
            drawPeg(canvasWidth / 2 + x, canvasHeight / 2 - y);
        } else if(Math.abs(Math.cos(angle)) < 1/sqrt(2) - 0.001) {
            /* These are the top/bottom sides */
            let y = Math.sign(Math.sin(angle)) * (side / 2 + 10);
            let x = Math.sign(Math.sin(angle)) * (side / 2) / Math.tan(angle);
            drawPeg(canvasWidth / 2 + x, canvasHeight / 2 - y);
        } else {
            /* These are the corners */
            let x = Math.sign(Math.cos(angle)) * (side / 2 + 10);
            let y = Math.sign(Math.sin(angle)) * (side / 2 + 10);
            drawPeg(canvasWidth / 2 + x, canvasHeight / 2 - y);
        }
    }
}

/* Draws a brown peg at (x, y). */
function drawPeg(x, y) {
    let brown = color(153, 51, 0);
    push();
    noStroke();
    fill(brown);
    circle(x, y, 10);
    pop();
}

function parsePegIndices(pegs, input) {
    /* sanitize input */
    let xs = input.split(',')
        .map(x => parseInt(x.trim()))
        .filter(x => !isNaN(x) && x >= 1 && x <= pegs);
    return xs;
}

function parseLines(pegs, input) {
    let xs = parsePegIndices(pegs, input);
    /* zip pegs into pairs, e.g. a, b, c, d into (a, b), (b, c), (c, d) */
    return xs.slice(0, -1).map((x, i) => [x, xs[i+1]]);
}
