$(document).ready(function() {
	var glob = {
		tilesize : 6,
		size : 48,
		basenoise : {},
		showTiming : true,
		timingTab : {},
		coord : [0, 0]
	};
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
	generate();
	$("#timing").hide();

	window.addEventListener( "keydown", doKeyDown, true);

	function doKeyDown(e) {
		var direction = "";

		switch (e.keyCode)
		{
		case 37:
		    direction = "W";
			glob.coord[0] = glob.coord[0] - 1;
			break;
		case 38:
			direction = "N";
			glob.coord[1] = glob.coord[1] - 1;
			break;
		case 39:
			direction = "E";
			glob.coord[0] = glob.coord[0] + 1;
			break;
		case 40:
			direction = "S";
			glob.coord[1] = glob.coord[1] + 1;
			break;
		}

		if (direction != "")
		{
			$("#hint").hide();
			shiftAndGenerate(direction)
		}
	}

	function generate() {
		$.getJSON("/shapegenweb/generate", { "size":glob.size }, function(returnedData) {
			glob.basenoise = returnedData.basenoise;
			drawShape(returnedData);
		});
	}

	function shiftAndGenerate(direction) {
		startTiming();

		var DataToSend = new Object();
		DataToSend = { "basenoise":glob.basenoise, "direction":direction,	"timing":glob.timingTab };

		$.ajax({
			type: "PUT",
			contentType: "application/json; charset=utf-8",
			url: '/shapegen/shift_and_generate',
			data: JSON.stringify(DataToSend),
			dataType: "json",
			success: function(returnedData) {
				glob.basenoise = returnedData.basenoise;
				glob.timingTab = returnedData.timing;
				endTiming();
				showTiming();
				drawShape(returnedData);
			},
			error: function (err){
				alert('Error: ' + err);
			}
		});
	}

	function squareSize() {
		return glob.size * glob.tilesize
	}

	function getSquareOffset() {
		return [glob.coord[0] * squareSize(), glob.coord[1] * squareSize()];
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
	
	function drawShape(shapeData) {
		clearSquare();
		ctx.fillStyle = "rgb(255,0,0)";
		var shape = shapeData.shape;
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

	function startTiming() {
		glob.timingTab = {};
		glob.timingTab["client start"] = (new Date()).getTime();
	}

	function endTiming() {
		glob.timingTab["client end"] = (new Date()).getTime();
	}

	function showTiming() {
		var timingHtml = "";
		var prevTiming = 0;
		if(glob.showTiming) {
			$("#timing").show();
			for (var timing in glob.timingTab) {
				if (glob.timingTab.hasOwnProperty(timing)) {
					if(prevTiming != 0) {
						timingHtml += (timing + "  " + (glob.timingTab[timing] - prevTiming) + " ms<br>");
					}
					prevTiming = glob.timingTab[timing];
				}
			}
			$("#timing").html(timingHtml);
		}
	}

});
