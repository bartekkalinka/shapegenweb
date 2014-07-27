<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>Getting Started: Serving Web Content</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
	<font face="courier">
		<p>${sizex}</p>
	    <table>	
			<c:forEach var="row" items="${shape}">
		    	<tr><td>${row}</td></tr> 
			</c:forEach>
	    </table>
    </font>
</body>
</html>