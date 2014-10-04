$(document).ready(function() {
	var glob = {
		tilesize : 6,
		shapeData : {},
		size : 48,
		showTiming : true,
		timingTab : {}
	};
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
	getAjaxShape();
	$("#timing").hide();

	window.addEventListener( "keydown", doKeyDown, true);

	function doKeyDown(e) {
		var direction = "";

		switch (e.keyCode)
		{
		case 37:
		    direction = "W";
			break;
		case 38:
			direction = "N";
			break;
		case 39:
			direction = "E";
			break;
		case 40:
			direction = "S";
			break;
		}

		if (direction != "")
		{
			$("#hint").hide();
			shiftAndGenerate(direction)
		}
	}

	function getAjaxShape() {
		$.getJSON("/shapegenweb/generate", { "sizex":glob.size, "sizey":glob.size, "iter":3, "cutoff":"false" }, function(returnedData) {
			glob.shapeData = returnedData;
			drawShape();
		});
	}

	function shiftAndGenerate(direction) {
		startTiming();

		var DataToSend = new Object();
		DataToSend = { "sizex":glob.size, "sizey":glob.size, "basenoise":glob.shapeData.basenoise, "direction":direction,
			"iter":3, "cutoff":"false", "timing":glob.timingTab };

		$.ajax({
			type: "PUT",
			contentType: "application/json; charset=utf-8",
			url: '/shapegen/shift_and_generate',
			data: JSON.stringify(DataToSend),
			dataType: "json",
			success: function(returnedData) {
				glob.shapeData = returnedData;
				glob.timingTab = returnedData.timing;
				endTiming();
				showTiming();
				drawShape();
			},
			error: function (err){
				alert('Error: ' + err);
			}
		});
	}
	
	function clearCanvas() {
		ctx.fillStyle = "rgb(0,0,0)";
		ctx.fillRect(0, 0, canvas.width, canvas.height);
	}
	
	function drawShape() {
		clearCanvas();
		ctx.fillStyle = "rgb(255,0,0)";
		var shape = glob.shapeData.shape;
		var offset = [
		    Math.floor((canvas.width / glob.tilesize - glob.shapeData.sizey) / 2), 
			Math.floor((canvas.height / glob.tilesize - glob.shapeData.sizex) / 2)
		];
		for(i=0; i<glob.shapeData.sizey; i+=1) {
		  for(j=0; j<glob.shapeData.sizex; j+=1) {
		    if(shape[j][i]) {
		      ctx.fillRect(
		    		  glob.tilesize * (offset[1] + j), 
		    		  glob.tilesize * (offset[0] + i), glob.tilesize, glob.tilesize
		      );
		    }
		  }
		}		
	}

	function autoLoop() {
		shiftAndGenerate();
		window.setTimeout(autoLoop, 500);	
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
