<%@ page import="edu.harvard.capstone.parser.Equipment" %>
<%@ page import="edu.harvard.capstone.editor.ExperimentalPlateSet" %>
<%@ page import="edu.harvard.capstone.user.Scientist" %>

	<!-- Highlight / Error -->
	<div id="userMsgPanel" ></div>
	<div class="col-sm-12">
			<!-- TABS -->				
				<div id="tabs" >
                    <ul>
                        <li><a href="#parsingTab">Parsing</a></li>
                        <li><a href="#plateTab">Plate</a></li>
                        <li><a href="#featuresTab">Features</a></li>
                    </ul>

                    <div id="parsingTab">
                    	<div>
                        	<input type="hidden" id="parsingId" autocomplete="off"/>
                            <label for="parsingName">Parsing Name</label>
                            <input type="text" id="parsingName" autocomplete="off"/>
                            <label for="machineName">Machine</label>
                            <input type="text" id="machineName" autocomplete="off"/>
                            <label for="selectedFile">Example File</label>
                             <span id="selectedFile">no file selected</span>
                             <span>Drag and Drop example file or ...</span>
                             <input type="file" id="files" name="files[]" multiple />
                             <button id="getFile">choose file(s)</button>
                             <label for="parsingDescription">Parsing Description</label>
                             <input type="text" id="parsingDescription" autocomplete="off" />
                    		 <label for="delimiterList">delimiter</label>	
                            <select name="delimiterList" id="delimiterList" size="3"></select>
                        </div>
                    </div>
                    <div id="plateTab">
                        <p>
                            Indicate the cell range that covers data for the first plate
                            in the example file either by highlighting the relevant cells
                            in the table to the left or by indicating the cell range in
                            the field below.
                        </p>
                        <div>
                            <label for="firstPlateCellRange">first plate cell range</label>
                            <input type="text" id="firstPlateCellRange" autocomplete="off"/>
                            <button id="applyFirstPlate">Apply</button>
                        </div>

                    </div>


                    <div id="featuresTab">
                        <div>
                            <label for="featureList">Feature List</label>
                            <select name="featureList" id="featureList" size="5"></select>
                            <label for="featureCellRange">Cell Range</label>
                            <input type="text" id="featureCellRange" autocomplete="off"/>
                            <label for="featureCategory">Category</label>
                            <input type="text" id="featureCategory" autocomplete="off"/>
                            <label for="featureLevel">Apply to</label>
                            <div>
                                <input type="radio" id="wellLevel" name="featureLevel" value="well" />well<br/>
                            </div>
                            <div>
                                <input type="radio" id="plateLevel" name="featureLevel" value="plate" />plate<br/>
                            </div>
                            <div>
                                <input type="radio" id="experimentLevel" name="featureLevel" value="experiment" />experiment<br/>
                            </div>
                            <label for="labelList">label List</label>
                            <select name="labelList" id="labelList" size="5"></select>
                        </div>

                        <div>
                            <button id="newFeature">new feature</button>
                            <button id="saveFeature">save feature</button>
                            <button id="deleteFeature">delete feature</button>
                            <button id="applyFeatures">apply</button>
                        </div>

                    </div>
                </div>

                <div id="plateIDSelection">
                    <div>
                        <div>
                            <label for="experiment">experiment</label>
                            <select id="experiment" name="experiment">
                                <option value="">Experiment</option>
                                 <g:each var="experiment" in="${ExperimentalPlateSet.findAllByOwner(Scientist.get(sec?.loggedInUserInfo(field:'id')))}">
                                    <option value="${experiment.id}">${experiment.name}</option>
                                </g:each>
                            </select>
                        </div>
                        <label for="plateList">
                            Plate List
                        </label>

                        <select name="plateList" id="plateList" size="5">
                        </select>
                    </div>
                    <div>
                        <label for="plateIDMatchMethod">Plate id match by</label>
                        <div id="plateIDMatchMethod">
                            <div>
                                <input type="radio" id="byFeature" name="plateIDMatchMethod" value="byFeature" />plate level feature<br/>
                            </div>
                            <div>
                                <input type="radio" id="byManualEntry" name="plateIDMatchMethod" value="byManualEntry" />manual entry<br/>
                            </div>
                        </div>
                    </div>
                    <br/>
                    <br/>
                    <div id="byFeatureMethod">
                        <p>
                            Select a plate level feature to serve as the plate identifier
                            for matching with the plates defined in the plate editor
                        </p>
                        <label for="plateLevelFeatureList">
                            plateLevelFeatureList
                        </label>

                        <select name="plateLevelFeatureList" id="plateLevelFeatureList" size="5">
                        </select>

                    </div>
                    <div id="byManualEntryMethod">
                        <p>
                            Enter a plate ID for each plate by selecting the plate in the
                            plate list above and then entering the plate id for that plate
                            in the field below and hitting the "set plate id" button.
                        </p>
                        <div>
                            <label for="plateID">plate identifier</label>
                            <select id="plateID" name="plateID"></select>
                        </div>
                        <div>
                            <button id="setPlateID">set plate id</button>
                        </div>
                    </div>
                    <br/>
                    <div>
                        <button id="returnToConfig">Go back to parsing configuration</button>
                        <button id="sendImportDataToServer">import and save the data</button>
                        <button id="downloadFileImport">Download file import</button>
                    </div>
                </div>

				<!--  END TABS -->
				
	</div> 
	
	<div class="col-sm-12"><div class="panel-body"></div></div>

	<div class="col-sm-12">
		<div id="gridPanel" class="panel panel-info">
			<div class="panel-heading">
				<h4 class="panel-title">Preview Output File</h4>
			</div>
			<div class="panel-body">
				<div id="myGrid" style="width:100%; height:600px;"></div>
			</div>
		</div>
	</div>

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

<asset:javascript src="jquery-1.11.2.min.js"/>
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
    <asset:javascript src="selectize.js"/>
    <asset:javascript src="parser/Range.js"/>
    <asset:javascript src="grid/Grid.js"/>
    <asset:javascript src="parser/ImportDataFileGenerator.js"/>
    <asset:javascript src="parser/GridHighlighter.js"/>
    <asset:javascript src="parser/FileExaminer.js"/>
    <asset:javascript src="parser/ColorPicker.js"/>
    <asset:javascript src="parser/ImportData.js"/>
    <asset:javascript src="parser/ParsingConfig.js"/>
    <asset:javascript src="parser/parsingConfigCreator.js"/>

