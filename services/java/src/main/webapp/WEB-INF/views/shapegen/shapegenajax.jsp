<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>Getting Started: Serving Web Content</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js">    </script>
</head>
<body>
    <div id="wrap">
      <canvas id="canv" width="300" height="300"></canvas>
    </div>
	<button id="btnGen">Generate</button>
	<button id="btnLoop">Loop</button>
    <button id="btnZoomIn">+</button>
    <button id="btnZoomOut">-</button>
    <br/>
    <!--  
    <input id="fieldSizex" type="number">10</input>
    <input id="fieldSizey" type="number">7</input>
    -->
</body>
<script type="text/javascript" src="<c:url value="/resources/shapegenajax.js" /> "></script>
</html>