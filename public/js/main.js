require.config({
    urlArgs: "bust=" + (new Date()).getTime()
});

requirejs(['js/timing', 'js/globals'], function(timing, glob) {
$(document).ready(function() {
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
    initshapeTab(10);
	getShapes();

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
		getShapes();
	}

    function getShapes() {
		timing.start();
        requestShape(0, 0);
        requestShape(0, 1);
        requestShape(1, 0);
        requestShape(1, 1);
    }

	function requestShape(dx, dy) {
        x = glob.coordx + dx;
        y = glob.coordy + dy;
        timing.log("requestShape " + x + " " + y);
		$.getJSON("/shapegenweb/" + x + "/" + y , { }, 
		  function(returnedData) {
            saveSquare(returnedData.shape, x, y);
			drawShape(x, y);
            timing.show();
		});
	}

	function squareSize() {
		return glob.size * glob.tilesize
	}

    function initshapeTab(n) {
        glob.shapeTab = new Array();
        for(i = 0; i < n; i++) {
            glob.shapeTab[i] = new Array();
        }
    }

    function saveSquare(shape, x, y) {
        timing.log("saveSquare " + x + " " + y);
        glob.shapeTab[x][y] = shape;

    }

    function getSquareShape(x, y) {
        timing.log("getSquareShape " + x + " " + y);
        return glob.shapeTab[x][y];
    }

	function getSquareOffset(dx, dy) {
		return [dx * squareSize(), dy * squareSize()];
	}

	function clearCanvas() {
		ctx.fillStyle = "rgb(0,0,0)";
		ctx.fillRect(0, 0, canvas.width, canvas.height);
	}
	
	function clearSquare(dx, dy) {
		var offset = getSquareOffset(dx, dy);
		ctx.fillStyle = "rgb(0,0,0)";
		ctx.fillRect(offset[0], offset[1], squareSize(), squareSize());
	}
	
	function drawShape(x, y) {
        dx = x - glob.coordx;
        dy = y - glob.coordy;
		clearSquare(dx, dy);
		ctx.fillStyle = "rgb(255,0,0)";
		var shape = getSquareShape(x, y);
		var offset = getSquareOffset(dx, dy);
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