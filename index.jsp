<%@ page contentType="text/html; charset=utf-8" language="java" import="java.net.URL,java.util.*,com.mks.api.*,com.mks.api.response.*"%>
<head>
  <meta charset="utf-8" />
</head>
<!--<div align='center' id="d3_selectable_force_directed_graph" style="width: 960px; height: 500px; margin: auto; margin-bottom: 12px">-->
<div align='center' id="d3_selectable_force_directed_graph" style="width: 1200px; height: 900px; margin: auto; margin-bottom: 12px">
  <svg />
</div>

<%
String sid = request.getParameter("id");
int startId = -1;
if (null != sid) {
	try {
		startId = Integer.parseInt(sid);
	} catch (Exception e) {
    String redirectURL = "error.jsp?msg=Invalid 'id' parameter. " + e.getMessage();
    response.sendRedirect(redirectURL);
	}
} else {
  String redirectURL = "error.jsp?msg=Invalid 'id' parameter.";
  response.sendRedirect(redirectURL);
}
%>

<link rel='stylesheet' href='d3v4-selectable-zoomable-force-directed-graph.css'>
<!--<script src="https://d3js.org/d3.v4.js"></script>-->
<script src="d3.v4.min.js"></script>
<script src="d3v4-brush-lite.js"></script>
<script src="d3v4-selectable-force-directed-graph.js"></script>

<%!
/**
 * Returns the API Exception message, or nested message if one is present.  Typically used inside catch block.
 * @param ae APIException to get message from
 * @return String message from current or nested exception
 */
public static String getAPIMessage(APIException ae) {
	String message = ae.getMessage();
	Response aeresp = ae.getResponse();

	if (aeresp != null) {
		// If there is a response object for the exception dig through it to find nested exception
		WorkItemIterator wit = aeresp.getWorkItems();
		try {
			while(wit.hasNext()) {
				wit.next(); // this loop works because .next() method throws the exception
			}
		}
		catch(APIException aenested) {
			// Catch any nested exception thrown while iterating through the loop
			String curMessage = aenested.getMessage();
			if(curMessage != null) {
				message = curMessage;
			}
		}
	}
	return message;
}
%>
<%
	ArrayList nodes = new ArrayList();
	ArrayList links = new ArrayList();
			try {
				String user = "administrator";
				String pass = "ptc";
				String host = "localhost";
				int port = 7001;
			  // Create server integration point
        CmdRunner cr = IntegrationPointFactory.getInstance().createIntegrationPoint(host, port, 4, 12).createSession(user, pass).createCmdRunner();
			  cr.setDefaultHostname(host);
			  cr.setDefaultPort(port);
			  cr.setDefaultUsername(user);
			  
			  Command cmd = new Command("im", "relationships");
				MultiValue fieldsMv = new MultiValue(",");
				fieldsMv.add("ID");
				fieldsMv.add("Name");
				fieldsMv.add("Text");
				fieldsMv.add("Category");
				fieldsMv.add("Shared Category");
				fieldsMv.add("Type");
				fieldsMv.add("Document ID");
				cmd.addOption(new Option("fields", fieldsMv));
				MultiValue traverseMv = new MultiValue(",");
				//for (String relationship : getRelationships()) {
				//		traverseMv.add(relationship);
				//}
				traverseMv.add("Contains");
				traverseMv.add("Satisfied By");
				traverseMv.add("Validated By");
				traverseMv.add("Verified By");
				traverseMv.add("Caused By");
				traverseMv.add("Mitigated By");
				traverseMv.add("Implemented By");
				cmd.addOption(new Option("traverseFields", traverseMv));
			  cmd.addSelection(""+startId);

			  Response res = cr.execute(cmd);

				WorkItemIterator wit = res.getWorkItems();
				while (wit.hasNext()) {
								WorkItem wi = wit.next();
								//String expandLevel = wi.getContext("expand-level");
								String id = wi.getField("ID").getValueAsString();
								String type = wi.getField("Type").getValueAsString();
								String category = wi.getField("Category").getValueAsString();
								String sharedcategory = wi.getField("Shared Category").getValueAsString();
								String text = wi.getField("Text").getValueAsString();
								String name = wi.getField("Name").getValueAsString();
								if (null != name) {
									name = name.replaceAll("'", "\\\\'");
								} else {
									name = "";
								}
								if (null != text) {
									text = text.replaceAll("'", "\\\\'");
									//text = text.replace(/(?:\r\n|\r|\n)/g, '<br />');
									text = text.replaceAll("\\\n", "<br />");
								} else {
									text = "";
								}
								if (null == category) {
									category = "";
								}
								if (null == sharedcategory) {
									sharedcategory = "";
								}
								String docId = wi.getField("Document ID").getValueAsString();
								String contains = wi.getField("Contains").getValueAsString();
								String validatedby = wi.getField("Validated By").getValueAsString();
								String verifiedby = wi.getField("Verified By").getValueAsString();
								String satisfiedby = wi.getField("Satisfied By").getValueAsString();
								String causedby = wi.getField("Caused By").getValueAsString();
								String mitigatedby = wi.getField("Mitigated By").getValueAsString();
								String implementedby = wi.getField("Implemented By").getValueAsString();
								String node = "{'id': '" + id + "', 'docId': '" + docId + "', 'name': '" + name + "', 'type': '" + type + "', 'category': '" + category + "', 'sharedcategory': '" + sharedcategory + "', 'text': '" + text + "', 'contains': '" + contains + "', 'validatedby': '" + validatedby + "', 'verifiedby': '" + verifiedby + "', 'satisfiedby': '" + satisfiedby + "', 'causedby': '" + causedby + "', 'mitigatedby': '" + mitigatedby + "', 'implementedby': '" + implementedby + "'}";
								nodes.add(node);
								//out.println(node);
				}
			  /*
			  Command cmdView = new Command("im", "issues");

			  WorkItem wi = res.getWorkItem(id);

			  String result = "";
			  if (wi.getField("Additional Comments") != null) {
				  result = wi.getField("Additional Comments").getValueAsString();
				  if (result == null) { result = ""; }
			  }
			  result = result.replaceAll("\\\n", "<br>");			  
			  response.setStatus(200);			  			  
			  out.println(result);
				*/
			
			} catch (APIException ae) {    
				System.out.println("API EXCEPTION");
        System.out.println(getAPIMessage(ae));
				response.setStatus(400);
				out.println("Integrity API Exception Posting Your Comment:");
        out.println(getAPIMessage(ae));
			} catch (Exception e) {
				System.out.println("Other exception!");
				e.printStackTrace();
				response.setStatus(500);
				out.println("Exception On Server While Posting Your Comment:");
        out.println(e.getMessage());
			}
%>

<script>
    var svg = d3.select('#d3_selectable_force_directed_graph');
		
		var jsonNodes = [];
		var jsonLinks = [];
		
		var weakLink = "50";
		var strongLink = "10";

		<%
    for(int i = 0; i < nodes.size(); i++) {
    %>
		var node = <%=nodes.get(i)%>;
		var o = new Object();
		o.id = node.id;
		o.type = node.type;
		o.docId = node.docId;
		o.name = node.name;
		o.text = node.text;
		o.category = node.category + node.sharedcategory;
    jsonNodes.push(o);
		var contains = node.contains;
		if (null != contains && contains.length > 0) {
			if (contains.indexOf(',') > 0) {
				var tokens = contains.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = strongLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = contains.replace(/\D/g,'');
				o.strength = strongLink;
				jsonLinks.push(o);
			}
		}
		var validatedby = node.validatedby;
		if (null != validatedby && validatedby.length > 0) {
			if (validatedby.indexOf(',') > 0) {
				var tokens = validatedby.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = weakLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = validatedby.replace(/\D/g,'');
				o.strength = weakLink;
				jsonLinks.push(o);
			}
		}
		var verifiedby = node.verifiedby;
		if (null != verifiedby && verifiedby.length > 0) {
			if (verifiedby.indexOf(',') > 0) {
				var tokens = verifiedby.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = weakLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = verifiedby.replace(/\D/g,'');
				o.strength = weakLink;
				jsonLinks.push(o);
			}
		}
		var satisfiedby = node.satisfiedby;
		if (null != satisfiedby && satisfiedby.length > 0) {
			if (satisfiedby.indexOf(',') > 0) {
				var tokens = satisfiedby.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = weakLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = satisfiedby.replace(/\D/g,'');
				o.strength = weakLink;
				jsonLinks.push(o);
			}
		}
		var causedby = node.causedby;
		if (null != causedby && causedby.length > 0) {
			if (causedby.indexOf(',') > 0) {
				var tokens = causedby.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = weakLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = causedby.replace(/\D/g,'');
				o.strength = weakLink;
				jsonLinks.push(o);
			}
		}
		var mitigatedby = node.mitigatedby;
		if (null != mitigatedby && mitigatedby.length > 0) {
			if (mitigatedby.indexOf(',') > 0) {
				var tokens = mitigatedby.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = weakLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = mitigatedby.replace(/\D/g,'');
				o.strength = weakLink;
				jsonLinks.push(o);
			}
		}
		var implementedby = node.implementedby;
		if (null != implementedby && implementedby.length > 0) {
			if (implementedby.indexOf(',') > 0) {
				var tokens = implementedby.split(",");
				for (var i=0; i<tokens.length; i++) {
					var o = new Object();
					o.source = node.id;
					o.target = tokens[i].replace(/\D/g,'');
					o.strength = weakLink;
					jsonLinks.push(o);
				}
			} else {
				var o = new Object();
				o.source = node.id;
				o.target = implementedby.replace(/\D/g,'');
				o.strength = weakLink;
				jsonLinks.push(o);
			}
		}
    <%
    }
    %>
		//console.log("JSON NODES: " + JSON.stringify(jsonNodes));
		//console.log("JSON LINKS: " + JSON.stringify(jsonLinks));
		
			/*
			"nodes": [
				{"id": strongLink, "docId": "1", "name": "MATT VOC 1", "type": "Requirement", "category": "Heading"},
				{"id": "12", "docId": "1", "name": "VOC 1.1", "type": "Requirement", "category": "Business Requirement"},
				{"id": "14", "docId": "1", "name": "VOC 1.2", "type": "Requirement", "category": "Business Requirement"},
				{"id": "20", "docId": "2", "name": "Risk 1", "type": "Risk", "category": "Failure Mode"},
				{"id": "22", "docId": "2", "name": "Risk 2", "type": "Risk", "category": "Failure Mode"},
				{"id": weakLink, "docId": "3", "name": "Test 1", "type": "Test Case", "category": "Functional Test"},
				{"id": "32", "docId": "3", "name": "Test 2", "type": "Test Case", "category": "Functional Test"},
				{"id": "34", "docId": "3", "name": "Test 3", "type": "Test Case", "category": "Functional Test"},
				{"id": "40", "docId": "4", "name": "REQ 1.1.2", "type": "Requirement", "category": "Functional Requirement"}
			],
			"links": [
				{"source": strongLink, "target": "12", "strength": 10},
				{"source": strongLink, "target": "14", "strength": 10},
				{"source": "14", "target": "20", "strength": 30},
				{"source": "14", "target": weakLink, "strength": 30},
				{"source": "20", "target": "40", "strength": 30}
			]
			*/

			var jsonData = {
			"nodes": 	jsonNodes,
			"links": jsonLinks
		};
		//jsonData.nodes = jsonNodes;
		//console.log(jsonData.nodes);
		console.log(jsonData);
		//console.log(JSON.parse(jsonNodes));
    createV4SelectableForceDirectedGraph(svg, jsonData);
</script>
