package edu.harvard.capstone.editor


import static org.springframework.http.HttpStatus.*
import edu.harvard.capstone.parser.Equipment;
import edu.harvard.capstone.result.Result;
import grails.plugin.springsecurity.annotation.Secured
import grails.converters.JSON

class ExperimentalPlateSetController {

    def springSecurityService
    def editorService

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

    @Secured(['ROLE_SCIENTIST', 'ROLE_ADMIN', 'ROLE_SUPER_ADMIN'])
    def index(Integer max) {
        if (!springSecurityService.isLoggedIn())
            return

        if(!springSecurityService.principal?.getAuthorities().any { it.authority == "ROLE_ADMIN" || it.authority == "ROLE_SUPER_ADMIN"}){
            params.owner = springSecurityService.principal
        }

        params.max = Math.min(max ?: 10, 100)
        def experiments = ExperimentalPlateSet.list(params)
        def resultsByExperiment = Result.list().collectEntries{ result ->
            [result.experiment, result]
        }
        def disabled = [:]
        def resultId = [:]
        for (experiment in experiments) {
            if (resultsByExperiment.containsKey(experiment)) {
                disabled[experiment.id] = ''
                resultId[experiment.id] = resultsByExperiment[experiment].id
            }
            else {
                disabled[experiment.id] = 'disabled'
                resultId[experiment.id] = ''
            }
        }

        respond experiments, model:[experimentalPlateSetInstanceCount: ExperimentalPlateSet.count(),
                                    disabled: disabled,
                                    resultId: resultId]
    }
	
	@Secured(['ROLE_SCIENTIST', 'ROLE_ADMIN', 'ROLE_SUPER_ADMIN'])
	def showactions(ExperimentalPlateSet experimentalPlateSetInstance) {
		if (!springSecurityService.isLoggedIn())
		return

		if(!springSecurityService.principal?.getAuthorities().any { it.authority == "ROLE_ADMIN" || it.authority == "ROLE_SUPER_ADMIN"}){
			params.owner = springSecurityService.principal
		}
		
		def plateSetList = PlateSet.findAllByExperiment(experimentalPlateSetInstance);
		respond experimentalPlateSetInstance, model:[plateSetlist: plateSetList]
	}
	
	@Secured(['ROLE_SCIENTIST', 'ROLE_ADMIN', 'ROLE_SUPER_ADMIN'])
	def createPlate() {
		if (!springSecurityService.isLoggedIn())
		return

		if(!springSecurityService.principal?.getAuthorities().any { it.authority == "ROLE_ADMIN" || it.authority == "ROLE_SUPER_ADMIN"}){
			params.owner = springSecurityService.principal
		}
		respond new PlateTemplate(params), model:[expId: params.expid, templateId: params.tmpid]
	}
	
	@Secured(['ROLE_SCIENTIST', 'ROLE_ADMIN', 'ROLE_SUPER_ADMIN'])
	def selectTemplate(ExperimentalPlateSet experimentalPlateSetInstance) {
		if (!springSecurityService.isLoggedIn())
		return

		if(!springSecurityService.principal?.getAuthorities().any { it.authority == "ROLE_ADMIN" || it.authority == "ROLE_SUPER_ADMIN"}){
			params.owner = springSecurityService.principal
		}
		respond experimentalPlateSetInstance
	}

    def barcodes(ExperimentalPlateSet experimentalPlateSetInstance){
        if (!experimentalPlateSetInstance) {
            render(contentType: "application/json") {
                [error: "No data received"]
            }
            return
        }

        def plateIDs = PlateSet.findAllByExperiment(experimentalPlateSetInstance).collect{it.barcode}
        render(contentType: "application/json") {
            [barcodes: plateIDs]
        }


    }

    def show(ExperimentalPlateSet experimentalPlateSetInstance) {
        respond experimentalPlateSetInstance
    }

    def showy(ExperimentalPlateSet experimentalPlateSetInstance) {
        render editorService.getExperimentData(experimentalPlateSetInstance) as JSON
    }


    def showWithTemplate(ExperimentalPlateSet experimentalPlateSetInstance) {
        def result = []
        if (!experimentalPlateSetInstance) {
            result = [error: "No such experiment"]
        }
        else {
            def plateSets = PlateSet.findAllByExperiment(experimentalPlateSetInstance)
	    

            def templateInstance = plateSet ? plateSet[0].plate : null
            def template = templateInstance ? editorService.getTemplate(templateInstance) : null
            result = [experiment: experimentalPlateSetInstance,
                      plateTemplate: template]
        }
        render result as JSON
    }

    def create() {
        respond new ExperimentalPlateSet(params)
    }

    def save(String name, String description) {

        if (!springSecurityService.isLoggedIn()){
            redirect action: "index", method: "GET"
            return
        }  

        def experimentalPlateSetInstance = editorService.newExperiment(name, description)

         if (experimentalPlateSetInstance == null) {
            notFound()
            return
        }

        if (experimentalPlateSetInstance.hasErrors()) {
            respond experimentalPlateSetInstance.errors, view:'create'
            return
        }  
        
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'experimentalPlateSet.label', default: 'ExperimentalPlateSet'), experimentalPlateSetInstance.id])
                redirect experimentalPlateSetInstance
            }
            '*' { respond experimentalPlateSetInstance, [status: CREATED] }
        }
    }

    def edit(ExperimentalPlateSet experimentalPlateSetInstance) {
        respond experimentalPlateSetInstance
    }


    def update(ExperimentalPlateSet experimentalPlateSetInstance) {
        if (experimentalPlateSetInstance == null) {
            notFound()
            return
        }

        if (experimentalPlateSetInstance.hasErrors()) {
            respond experimentalPlateSetInstance.errors, view:'edit'
            return
        }

        experimentalPlateSetInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'ExperimentalPlateSet.label', default: 'ExperimentalPlateSet'), experimentalPlateSetInstance.id])
                redirect experimentalPlateSetInstance
            }
            '*'{ respond experimentalPlateSetInstance, [status: OK] }
        }
    }

    def delete(ExperimentalPlateSet experimentalPlateSetInstance) {

        if (experimentalPlateSetInstance == null) {
            notFound()
            return
        }

        experimentalPlateSetInstance.delete flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'ExperimentalPlateSet.label', default: 'ExperimentalPlateSet'), experimentalPlateSetInstance.id])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'experimentalPlateSet.label', default: 'ExperimentalPlateSet'), params.id])
                redirect action: "index", method: "GET"
            }
            '*'{ render status: NOT_FOUND }
        }
    }
}
