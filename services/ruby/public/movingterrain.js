$(document).ready(function() {
	var glob = {
		tilesize : 12,
		shapeData : {},
		size : 50
	};
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
	$('#btnGen').click(function() {
		getAjaxShape();
	});
	$('#btnShift').click(function() {
		shiftAndGenerate();
	});
	$('#btnLoop').click(function() {
		autoLoop();
	});

	function getAjaxShape() {
		$.getJSON("/shapegenweb/generate", { "sizex":glob.size, "sizey":glob.size, "iter":3, "cutoff":"false" }, function(returnedData) {
			glob.shapeData = returnedData;
			drawShape();
		});
	}

	function shiftAndGenerate() {
		var DataToSend = new Object();
		DataToSend = { "sizex":glob.size, "sizey":glob.size, "basenoise":glob.shapeData.basenoise, "iter":3, "cutoff":"false" };

		$.ajax({
			type: "PUT",
			contentType: "application/json; charset=utf-8",
			url: '/shapegen/shift_and_generate',
			data: JSON.stringify(DataToSend),
			dataType: "json",
			success: function(returnedData) {
				glob.shapeData = returnedData;
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

});
