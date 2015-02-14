define( ['js/globals'], function (glob) {
	var start = function () {
		glob.timingTab = {};
		glob.timingTab["client start"] = (new Date()).getTime();
	}

	var end = function () {
		glob.timingTab["client end"] = (new Date()).getTime();
	}

    var log = function(str) {
        glob.timingTab[str] = (new Date()).getTime();
    }

	var show = function () {
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

	return {
		"start" : start,
		"end" : end,
        "log" : log,
		"show" : show
	};
});