$(document).ready(function() {
	var glob = {
		tilesize : 15,
		shapeData : {}
	};
	var canvas = document.getElementById("canv");
	var ctx = canvas.getContext("2d");	
	clearCanvas();
	$('#btnGen').click(function() {
		getAjaxShape();
	});
	$('#btnLoop').click(function() {
		autoLoop();
	});
	$('#btnZoomIn').click(function() {
		glob.tilesize = glob.tilesize * 1.2;
		drawShape();
	});
	$('#btnZoomOut').click(function() {
		glob.tilesize = glob.tilesize / 1.2;		
		drawShape();
	});
	
	function getAjaxShape() {
		var sizex = $('#sizex').val();
		var sizey = $('#sizey').val();
		$.getJSON("/shapegenweb/generate", { "sizex":sizex, "sizey":sizey}, function(returnedData) {
			glob.shapeData = returnedData;
			drawShape();
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
		getAjaxShape();
		window.setTimeout(autoLoop, 500);	
	}	
});
