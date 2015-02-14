$(document).ready(function() {

    $('#btnGen').click(function() {
		ajaxGenerate();
	});

	function ajaxGenerate() {
        $("#status").html("Waiting...");
		$.get("/shapegenweb/generate", { }, function(data) {
			$("#status").html("Done");
		});
	}
});