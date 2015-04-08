<!DOCTYPE html>
<html>
	<head lang="en">
		<meta name="layout" content="main">
		<g:set var="entityName" value="${message(code: 'experimentalPlateSet.label', default: 'ExperimentalPlateSet')}" />
		<title><g:message code="default.create.label" args="[entityName]" /></title>
		
		<asset:stylesheet href="jquery-ui.css"/>
	    <asset:stylesheet href="grid/style.css"/>
	    <asset:stylesheet href="grid/slick.grid.css"/>
	    <asset:stylesheet href="grid/slick-default-theme.css"/>
	    <asset:stylesheet href="grid/Grid.css"/>
	    
	</head>
	<body>
		<div class="">
			
		</div>
	
		<div class="content-fluid ">
			<div class="row">
				<div class="col-sm-12">
					<ol class="breadcrumb">
						<li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
						<li><g:link controller="experimentalPlateSet" action="index">Experiments</g:link></li>
						<li><g:link controller="experimentalPlateSet" action="showactions" id="${experimentalPlateSetInstance.id}">Show Experiment</g:link></li>
					</ol>						
				</div>
				<!-- Right Column -->
				<div class="col-sm-12 content-body" style="padding-left: 50px">
					<h2>Selected Experiment:</h2>
					<p> Experiment ID: ${experimentalPlateSetInstance.id}</p>
					<p> Experiment Name: ${experimentalPlateSetInstance.name}</p>
					<p> Experiment Description: ${experimentalPlateSetInstance.description}</p>
					<p> Experiment Owner: ${experimentalPlateSetInstance.owner}</p>
					
					<p> Experiment Plates: !! List of plates for this Experiment !!</p>
				
					<h4>Add Plate to Experiment:</h4>
					<g:link id="${experimentalPlateSetInstance.id}" action="selectTemplate" class="btn btn-info">Select Existing Template</g:link>
					<g:link id="${experimentalPlateSetInstance.id}" controller="plateTemplate" action="create" class="btn btn-info">Create New Template</g:link>
				</div> <!-- Right Column END -->	
			</div>
		</div>
	</body>
</html>