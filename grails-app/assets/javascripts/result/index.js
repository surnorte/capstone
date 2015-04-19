var experiment;
var grid;


function init() {
    createGrid();
    var experimentId = $('#experimentSelect option:selected')[0].value;
    experimentSelected(experimentId); // calls plateSelected for us
}
window.onload = init;


function experimentSelected(experimentId) {
    experiment = new ExperimentModel(experimentId);
    experiment.getData().done(function () {
        var select = $('#plateSelect');
        select.children('option').remove();
        if (Object.keys(experiment.plates).length > 0) {
            var options = $.map(experiment.plates, function(p) {
                var option = $('<option />').text(p.barcode);
                if (p.barcode === experiment.currentPlateBarcode) {
                    option[0].selected = true;
                }
                return option;
            });
            select.append(options);
            plateSelected(experiment.currentPlateBarcode);
        }
    });
}


function plateSelected(barcode) {
    experiment.selectPlate(barcode);
    loadGrid(experiment.data);
    $('input[name="rawOrNorm"][value="raw"]')[0].checked = true;
    $('#zFactor').text(experiment.zFactor());
    $('#zPrimeFactor').text(experiment.zPrimeFactor());
    $('#dump').text(JSON.stringify(experiment.currentPlate, null, 4));
}


function createBlankData(width, height) {
    var result = [];
    for (var i=0; i<width; i++) {
        result[i] = [];
        for (var j=0; j<height; j++) {
            result[i][j] = null;
        }
    }
    return result;
}


function createGrid() {
    grid  = new Grid("resultGrid");
    loadGrid(createBlankData(100,100));
}


function loadGrid(dataSet) {
    grid.setData(dataSet);
    grid.fillUpGrid();
}


function toggleRawOrNorm(input) {
    if (input.value === 'norm') {
        loadGrid(experiment.normalizedData);
    }
    else {
        loadGrid(experiment.data);
    }
}
