requirejs(['timing', 'globals'], function(timing, glob) {
$(document).ready(function() {
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
	requestShape(glob.coordx, glob.coordy);
	$("#timing").hide();

	window.addEventListener( "keydown", doKeyDown, true);

	function doKeyDown(e) {

		switch (e.keyCode)
		{
		case 37:
			glob.coordx = glob.coordx - 1;
			break;
		case 38:
			glob.coordy = glob.coordy - 1;
			break;
		case 39:
			glob.coordx = glob.coordx + 1;
			break;
		case 40:
			glob.coordy = glob.coordy + 1;
			break;
		}

		$("#hint").hide();
		timing.start();
		requestShape(glob.coordx, glob.coordy)
        timing.end();
        timing.show();
	}

	function requestShape(x, y) {
		$.getJSON("/shapegenweb/" + x + "/" + y , { }, 
		  function(returnedData) {
            saveSquare(returnedData.shape, x, y);
			drawShape();
		});
	}

	function squareSize() {
		return glob.size * glob.tilesize
	}

    function saveSquare(shape) {
        if(!!!glob.shapetab[glob.coordx]) {
            glob.shapetab[glob.coordx] = [];
        }
        glob.shapetab[glob.coordx][glob.coordy] = shape;
    }

    function getSquareShape() {
        return glob.shapetab[glob.coordx][glob.coordy];
    }

	function getSquareOffset() {
		return [glob.coordx * squareSize(), glob.coordy * squareSize()];
	}

	function clearCanvas() {
		ctx.fillStyle = "rgb(0,0,0)";
		ctx.fillRect(0, 0, canvas.width, canvas.height);
	}
	
	function clearSquare() {
		var offset = getSquareOffset();
		ctx.fillStyle = "rgb(0,0,0)";
		ctx.fillRect(offset[0], offset[1], squareSize(), squareSize());
	}
	
	function drawShape() {
		clearSquare();
		ctx.fillStyle = "rgb(255,0,0)";
		var shape = getSquareShape();
		var offset = getSquareOffset();
		for(i=0; i<glob.size; i+=1) {
		  for(j=0; j<glob.size; j+=1) {
		    if(shape[j][i]) {
		      ctx.fillRect(
		    		  offset[0] + glob.tilesize * j, 
		    		  offset[1] + glob.tilesize * i, glob.tilesize, glob.tilesize
		      );
		    }
		  }
		}		
	}

}); //$(document).ready
}); //requirejs