// HACK - this module assumes several urls are set as globals by grails
// 	      when rendering the template for the page.

/**
 * Aggregates template, plate set, and result data from an experiment
 * for display and download.  Most functions operate on the "current"
 * plate by default, but will also accept a plateID as an argument.
 * Notable exceptions are the load*DataForGrid() functions.
 *
 * TODO - remove concept of current plate, refactor to operate on
 *        Plate objects instead.
 */
function ExperimentModel() {
    // experiment-wide data
    this.experiment = {plates: {}};
    this.numColumns = 0;
    this.numRows = 0;
    this.plates = {}; // keyed by plateID

    // updated every time we change plates
    this.controls = {'negative': null, 'positive': null};
    this.currentPlate = null;
    this.currentPlateID = null;
    this.data = null;
    this.normalizedData = null;


    this.fromJson = function(importDataJson) {
        if (!importDataJson || $.isEmptyObject(importDataJson)) {
            return;
        }

        // TODO - catch exceptions?
        this.experiment = JSON.parse(importDataJson);

        if (Object.keys(this.experiment.plates).length > 0) {
            for (var i=0; i<this.experiment.plates.length; i++) {
                var plate = this.experiment.plates[i];

                // elsewhere, we assume this exists, so make sure it does
                if (!plate.rawData) {
                    plate.rawData = {};
                }

                // figure out the size of the plates
                this.numRows = Math.max(this.numRows, plate.rows.length);
                var columnCounts = plate.rows.map(function (row) {
                    return row.columns.length;
                });
                this.numColumns = Math.max(this.numColumns,
                                           Math.max.apply(null, columnCounts));

                // store it by plate id
                this.plates[plate.plateID] = plate;
            }
            this.selectPlate(this.experiment.plates[0].plateID);
        }
    }


    /**
     * Returns empty 2d array in the shape of the plates for this experiment.
     */
    this.getEmptyGrid = function() {
        var empty = [];
        for (var x=0; x<this.numRows; x++) {
            empty.push(new Array(this.numColumns));
        }
        return empty;
    }

    /**
     * Copies the raw data on the current plate into a 2d array to supply
     * to slickgrid.
     */
    this.loadDataForGrid = function() {
        var label = this.rawDataLabel();

        // create an empty array no matter what
        this.data = this.getEmptyGrid();

        // if there's data, fill it in
        for (var x=0; x<this.currentPlate.rows.length; x++) {
            for (var y=0; y<this.currentPlate.rows[0].columns.length; y++) {
                var well = this.currentPlate.rows[x].columns[y]
                if (!$.isEmptyObject(well.rawData)) {
                    this.data[x][y] = well.rawData[label];
                }
            }
        }
    }


    /**
     * Normalizes the raw data on the current plate, stores it in a 2d array
     * to supply to slickgrid.
     */
    this.loadNormalizedDataForGrid = function() {
        var label = this.rawDataLabel();

        this.normalizedData = this.getEmptyGrid();
        for (var x=0; x<this.currentPlate.rows.length; x++) {
            for (var y=0; y<this.currentPlate.rows[0].columns.length; y++) {
                var well = this.currentPlate.rows[x].columns[y];
                if (!$.isEmptyObject(well.normalizedData)) {
                    this.normalizedData[x][y] = well.normalizedData[label];
                }
            }
        }
    }


    /**
     * Walks the current plate, stores the coordinates of the negative
     * and positive control wells.
     */
    this.locateControls = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var plate = this.plates[plateID];
        var controls = {'negative': [], 'positive': []};

        for (var x=0; x<plate.rows.length; x++) {
            for (var y=0; y<plate.rows[x].columns.length; y++) {
                var controlType = plate.rows[x].columns[y].control;
                switch (controlType) {
                    case 'NEGATIVE':
                    case 'POSITIVE':
                        controls[controlType.toLowerCase()].push([x, y]);
                        break;
                }
            }
        }
       
        if (plateID === this.currentPlateID) {
            this.controls = controls;
        }
        return controls;
    }


    /**
     * returns the mean of the negative control values.
     */
    this.meanNegativeControl = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var rawLabel = this.rawDataLabel(plateID);
        if (!rawLabel) {
            return null;
        }
        var meanLabel = rawLabel + '__meanNegativeControl';

        var plate;
        var controls;
        if (plateID === this.currentPlateID) {
            plate = this.currentPlate;
            controls = this.controls;
        }
        else {
            plate = this.plates[plateID];
            controls = this.locateControls(plateID);
        }

        var rv;
        if ((meanLabel in plate.rawData) && (plate.rawData[meanLabel] !== null)) {
            rv = plate.rawData[meanLabel];
        }
        else {
            rv = d3.mean(controls.negative.map(function(coords) {
                return plate.rows[coords[0]].columns[coords[1]].rawData[rawLabel];
            }));
            plate.rawData[meanLabel] = rv;
        }
        return rv;
    }


    /**
     * returns the mean of the negative control values.
     */
    this.meanPositiveControl = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var rawLabel = this.rawDataLabel(plateID);
        if (!rawLabel) {
            return null;
        }
        var meanLabel = rawLabel + '__meanPositiveControl';

        var plate;
        var controls;
        if (plateID === this.currentPlateID) {
            plate = this.currentPlate;
            controls = this.controls;
        }
        else {
            plate = this.plates[plateID];
            controls = this.locateControls(plateID);
        }

        var rv;
        if ((meanLabel in plate.rawData) && (plate.rawData[meanLabel] !== null)) {
            rv = plate.rawData[meanLabel];
        }
        else {
            rv = d3.mean(controls.positive.map(function(coords) {
                return plate.rows[coords[0]].columns[coords[1]].rawData[rawLabel];
            }));
            plate.rawData[meanLabel] = rv;
        }
        return rv;
    }


    /**
     * Normalizes the data for the given plate, and saves it back to the 
     * server.
     */
    this.normalizeDeriveAndSave = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var label = this.rawDataLabel(plateID);
        var plate;
        var controls;

        if (plateID === this.currentPlateID) {
            plate = this.currentPlate;
            controls = this.controls;
        }
        else {
            plate = this.plates[plateID];
            controls = this.locateControls(plateID);
        }

        var normalized = normalize(plate, label,
                                   controls.negative, controls.positive);
        for (var x=0; x<plate.rows.length; x++) {
            for (var y=0; y<plate.rows[0].columns.length; y++) {
                plate.rows[x].columns[y].normalizedData[label]
                    = normalized[x][y].toString();
            }
        }

        // make sure we've also calculated the plate-level derived values as well
        this.zFactor(plateID);
        this.zPrimeFactor(plateID);
        this.meanNegativeControl(plateID);
        this.meanPositiveControl(plateID);

        var url = RESULT_SAVE_REFACTORED_DATA_URL + '/' + this.experiment.resultID;
        var jqxhr = $.ajax({
            url: url,
            contentType: 'application/json; charset=UTF-8',
            data: JSON.stringify(this.experiment),
            method: 'POST',
            processData: false,
        });
        jqxhr.done(function() {
            console.log('POST of normalized data for plate '
                        + plateID + ' complete');
        });
    }


    /**
     * Picks the first raw data label from the first well on the plate.
     *
     * Our backend supports more than one data value per well, but our
     * qa/qc and results display doesn't.
     */
    this.rawDataLabel = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var plate = this.plates[plateID];
        if (plate.rows[0].columns[0].rawData) {
            try {
                return Object.keys(plate.rows[0].columns[0].rawData).sort()[0];
            }
            catch (e) {
                console.log('rawDataLabel couldn\'t find rawData for plate '
                            + plateID);
                console.log(e);
                return null;
            }
        }
        else {
            return null;
        }
    }


    /**
     * Marks the plate with plateID plateID as the active one.  Copies data
     * from that plate into a 2d array we can feed to slickgrid.  Locates the
     * control wells for the plate.  Calculates and stores normalized data 
     * into a 2d array we can feed to slickgrid.
     *
     * TODO - put call to normalize and store normalized data into output
     * 	      parser.
     */
    this.selectPlate = function(plateID) {
        if (!$.isEmptyObject(this.plates) && (plateID in this.plates)) {
            this.currentPlate = this.plates[plateID];
            this.currentPlateID = plateID;
            this.locateControls(plateID);
            this.loadDataForGrid();
            this.loadNormalizedDataForGrid();
            if ($.isEmptyObject(this.currentPlate.rows[0].columns[0].normalizedData)) {
                this.normalizeDeriveAndSave();
            }
        }
        else {
            this.currentPlate = null;
            this.currentPlateID = null;
            this.data = this.getEmptyData();
            this.normalizedData = this.getEmptyData();
        }
    }


    /**
     * Calculates the z-factor value for the current plate.
     */
    this.zFactor = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var rawLabel = this.rawDataLabel(plateID);
        if (!rawLabel) {
            return null;
        }
        var zFactorLabel = rawLabel + '__zFactor';

        var plate;
        var controls;
        if (plateID === this.currentPlateID) {
            plate = this.currentPlate;
            controls = this.controls;
        }
        else {
            plate = this.plates[plateID];
            controls = this.locateControls(plateID);
        }
        
        var rv;
        if ((zFactorLabel in plate.rawData) && (plate.rawData[zFactorLabel] !== null)) {
            rv = plate.rawData[zFactorLabel];
        }
        else {
            rv = zFactor(plate, rawLabel,
                         controls.negative, controls.positive);
            plate.rawData[zFactorLabel] = rv;
        }
        return isNaN(rv) ? null : rv;
    }


    /**
     * Calculates the z'-factor value for the current plate.
     */
    this.zPrimeFactor = function(plateID) {
        plateID = (plateID === undefined) ? this.currentPlateID : plateID;
        var rawLabel = this.rawDataLabel(plateID);
        if (!rawLabel) {
            return null;
        }
        var zPrimeFactorLabel = rawLabel + '__zPrimeFactor';
        var plate;
        var controls;

        if (plateID === this.currentPlateID) {
            plate = this.currentPlate;
            controls = this.controls;
        }
        else {
            plate = this.plates[plateID];
            controls = this.locateControls(plateID);
        }

        var rv;
        if ((zPrimeFactorLabel in plate.rawData) && (plate.rawData[zPrimeFactorLabel] !== null)) {
            rv = plate.rawData[zPrimeFactorLabel];
        }
        else {
            rv = zPrimeFactor(plate, rawLabel,
                              controls.negative, controls.positive);
            plate.rawData[zPrimeFactorLabel] = rv;
        }
        return isNaN(rv) ? null : rv;
    }
}
