require.config({
    urlArgs: "bust=" + (new Date()).getTime()
});

requirejs(['js/timing', 'js/globals'], function(timing, glob) {
$(document).ready(function() {
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
    initshapeTab(3);
	getShapes();
	setInterval(function() {
        requestMoreDetail(0, 0);
        requestMoreDetail(0, 1);
        requestMoreDetail(1, 0);
        requestMoreDetail(1, 1);
	}, 1000);

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
		$.getJSON("/sector/" + x + "/" + y + "/get", { },
		  function(returnedData) {
            saveSquare(returnedData, dx, dy);
			drawShape(dx, dy);
            timing.show();
		});
	}

	function requestMoreDetail(dx, dy) {
	    level = getSquareLevel(dx, dy)
	    if(level == 12) {
	        return;
	    }
	    gx = glob.coordx;
	    gy = glob.coordy;
	    x = gx + dx;
        y = gy + dy;
    	$.getJSON("/sector/" + x + "/" + y + "/moreDetail", { },
		  function(returnedData) {
		  	if(gx === glob.coordx && gy === glob.coordy) {
				saveSquare(returnedData, dx, dy);
				drawShape(dx, dy);
				timing.show();
            }
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

    function saveSquare(shapeData, dx, dy) {
        glob.shapeTab[dx][dy] = shapeData;

    }

    function getSquareShape(dx, dy) {
        return glob.shapeTab[dx][dy].noise;
    }

    function getSquareDetail(dx, dy) {
        return glob.shapeTab[dx][dy].detail;
    }

    function getSquareLevel(dx, dy) {
        return glob.shapeTab[dx][dy].level;
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
	
	function drawShape(dx, dy) {
		clearSquare(dx, dy);
		ctx.fillStyle = "rgb(255,0,0)";
		var shape = getSquareShape(dx, dy);
		var offset = getSquareOffset(dx, dy);
		var detailScale = Math.pow(2, getSquareDetail(dx, dy))
		var size = glob.size * detailScale
		var tilesize = glob.tilesize / detailScale
		for(i=0; i<size; i+=1) {
		  for(j=0; j<size; j+=1) {
		    if(shape[j][i] >= 500) {
		      ctx.fillRect(
		    		  offset[0] + tilesize * j,
		    		  offset[1] + tilesize * i, tilesize, tilesize
		      );
		    }
		  }
		}		
	}

}); //$(document).ready
}); //requirejs