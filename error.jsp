<html>
<head>
  <title>Error</title>
</head>
<body>
Error processing force directed graph.
<p>
<%
String msg = request.getParameter("msg");
if (null != msg) {
  out.println(msg);
}
%>
</body>
</html>
