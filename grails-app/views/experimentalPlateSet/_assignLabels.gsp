
<div class="col-xs-8">
	<div id="labelPanel" class="panel panel-info">
		<div class="panel-heading">
			<div class="panel-title">Add New Label: 
				<label>Type:</label>
				<div class="btn-group" data-toggle="buttons">
	                <label class="btn btn-default btn-sm active">
	                    <input type="radio" name="labeltype" id="catLabType"/>Label
	                </label>
	                <label class="btn btn-default btn-sm">
	                    <input type="radio" name="labeltype" id="doseLabType"/>Dose
	                </label>
	                <label class="btn btn-default btn-sm">
	                    <input type="radio" name="labeltype" id="doseStepLabType"/>Dose Step
	                </label>
	            </div>
				<label>Level:</label>
				<div class="btn-group" data-toggle="buttons">
	                <label class="btn btn-default btn-sm active">
	                    <input type="radio" name="labellevel" id="wellLevel"/> well
	                </label>
	                <label class="btn btn-default btn-sm">
	                    <input type="radio" name="labellevel" id="plateLevel"/> plate
	                </label>
	                <label class="btn btn-default btn-sm">
	                    <input type="radio" name="labellevel" id="plateSetLevel"/> plate-set
	                </label>
	            </div>
            </div>
		</div>
		<div class="panel-body">
            <div class="toggler">
	            <div id="addLabelPanel">
		            <label>Category:</label> <input type="text" id="newCatValue"/>
					<label>Label:</label><input type="text" id="newLabelValue"/>
					<label>Color:</label><input type="color" class="btn-default" id="newColorValue" value="#FFFF00"/>
					<button id="addNewLabel" class="btn btn-default btn-sm glyphicon glyphicon-plus"></button>
				</div>
			</div>
			
			<!-- need to hide this or label, depending on which is selected in label type ? -->
			<div class="toggler">
				<div id="addDosePanel">
					<label>Dosage:</label><input type="text" id="newDoseValue"/>
					<label>Units:</label><input type="text" id="newDoseUnits"/>
					<label>Color:</label><input type="color" class="btn-default" id="newDoseColorValue" value="#FFFF00"/>
					<button id="addNewDose" class="btn btn-default btn-sm glyphicon glyphicon-plus"></button>
				</div>
			</div>
			
			<!-- need to hide this or label, depending on which is selected in label type ? -->
			<div class="toggler">
				<div id="addDoseStepPanel">
					<label>Top Dose:</label><input type="text" id="topDoseValue"/>
					<label>Units:</label><input type="text" id="doseStepUnits"/>
					<label>Step Dilution:</label><input type="text" id="stepDilutionValue"/>
					<label># of Replicates:</label><input type="text" id="replicatesValue" value="1"/>
					<label>Top Dose Color:</label><input type="color" class="btn-default" id="tDoseColorValue" value="#FFFF00"/>
					<button id="addDoseStep" class="btn btn-default btn-sm glyphicon glyphicon-plus"></button>
				</div>
			</div>
		
			<div id="editLabelDialog" title="New Label Name">
				<input type="text" id="editNewLabelValue"/>
			</div>
		</div>
	</div>
	
	
	<!-- <div class="col-xs-4">
		<div id="otherPanel" class="panel panel-info">
			<div class="panel-heading">
				<h4 class="panel-title">Other Actions</h4>
			</div>
			<div class="panel-body">
				<div>Plate Barcode:<input type="text" id="barcode"/></div>
				<div>Cell Range Selected:<span id="cellRange"></span></div>
			</div>
		</div>
	</div> -->
	

	<div id="gridPanel" class="panel panel-info">
		<div class="panel-heading">
			<h4 class="panel-title">Plate Wells:<button id="clearAllSelection" >Clear Selection</button></h4>
		</div>
		<div class="panel-body">
			<div id="myGrid" style="width:100%; height:650px;"></div>
		</div>
	</div>
</div>

<div class="col-xs-2">
	<div id="categoryPanel" class="panel panel-info">
		<div class="panel-heading">
			<h4 class="panel-title">Categories</h4>
		</div>
		<div class="panel-body">
			<div id="categoryList"></div>
		</div>
	</div>
</div>

<div class="col-xs-2">
	<div id="compoundPanel" class="panel panel-info">
		<div class="panel-heading">
			<h4 class="panel-title">Compounds</h4>
		</div>
		<div class="panel-body">
			<div id="compoundList"></div>
		</div>
	</div>
</div>


<div id="templateVals">${templateInstance}</div>

<g:if env="production">
    <!-- Markup to include ONLY when in production -->
    <g:javascript>
        var hostname = "";
    </g:javascript>
</g:if>
<g:else>
    <g:javascript>
        var hostname = "/capstone";       
    </g:javascript> 
</g:else>

<asset:javascript src="jquery-ui.js"/>
<asset:javascript src="jquery.event.drag-2.2.js"/>
<asset:javascript src="grid/slick.core.js"/>
<asset:javascript src="grid/slick.grid.js"/>
<asset:javascript src="grid/slick.autotooltips.js"/>
<asset:javascript src="grid/slick.cellrangedecorator.js"/>
<asset:javascript src="grid/slick.cellrangeselector.js"/>
<asset:javascript src="grid/slick.cellcopymanager.js"/>
<asset:javascript src="grid/slick.cellselectionmodel.js"/>
<asset:javascript src="grid/slick.editors.js"/>
<asset:javascript src="grid/Grid2Merge.js"/>
<asset:javascript src="plateEditor/editorAssignLabels.js"/>


