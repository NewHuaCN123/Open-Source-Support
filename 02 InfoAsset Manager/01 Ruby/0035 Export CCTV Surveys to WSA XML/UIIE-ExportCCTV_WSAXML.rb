## IEXCHANGE CONFIG

$database = "//localhost:40000/DATABASE"				##Database Location & Name
$networkID = 4				##Network ID number
$exportLoc = "C:\\Temp\\"				##Export location folder
$configLoc = File.dirname(WSApplication.script_file)
$logFile = $exportLoc+"Output.txt"				##Log file location & name
$filenamePrefix="\\"#"export_"+Time.now.strftime("%Y%m%d_%H%M")+"_"
$projectID="uuid"				##Default Project ID if null on survey or single XML
$comments=""				##Comments for XML root header
$files=false				##Individual XML files per survey	>> Boolean

## END OF IEXCHANGE CONFIG



# require 'fileutils'
require 'securerandom'
require 'Date'
require 'rexml/document'
require 'etc'

startingTime = Process.clock_gettime(Process::CLOCK_MONOTONIC)

if WSApplication.ui?
	db = WSApplication.current_database
	nw = WSApplication.current_network 

	val=WSApplication.prompt "Export WSA XML",
	[
	['Export folder location:','String','C:\TEMP',nil,'FOLDER','Files folder'],
	['Filename prefix:','String'],
	['Project ID:','String','uuid'],
	['Project ID for null values in IAM.','Readonly','uuid'],
	['Project Comments:','String',nil],
	['Individual XML files','Boolean',true],
	['True = one XML per survey.','Readonly','X'],
	['Export Selection only','Boolean',false],
	],false
	if val==nil
		WSApplication.message_box("Parameters dialog closed\nScript cancelled",'OK','!',nil)
		abort("Invalid parameters.")
		exit
	else
		puts "[,,]\n"+val.to_s

		$exportLoc=val[0].to_s
		$filenamePrefix="\\"+val[1].to_s
		$projectID=val[2].to_s
		$comments=val[4]
		$files=val[5]
		$selection=val[7]

		if val[0]==nil
			WSApplication.message_box("Files folder required\nScript cancelled",'OK','!',nil)
			abort("Invalid parameters.")
			exit
		elsif val[2]==nil
			$projectID="uuid"
		end
		

		$logFile = File.open($logFile, 'w')
		def log(str = '')
			puts str
			$logFile.puts str
		end
	end
else
	db = WSApplication.open($database)
	mo = db.model_object_from_type_and_id('Collection Network', $networkID)
	nw = mo.open

	$selection=false

	$logFile = File.open($logFile, 'w')
	def log(str = '')
		puts str
		$logFile.puts str
	end
end

def method
end


v=WSApplication.version
currtime=Time.now.strftime("%F %T")
if $projectID=="uuid"
	$projectID=SecureRandom.uuid
end
if ($filenamePrefix==nil || $filenamePrefix=="\\") && $files==false
	$filenamePrefix=$filenamePrefix+"export_"+Time.now.strftime("%Y%m%d_%H%M")
end

list=Array.new
if $selection==true
	list=nw.row_objects_selection('cams_cctv_survey')
elsif $selection==false
	list=nw.row_objects('cams_cctv_survey')
end
n=list.count
log "Surveys to export: "+ n.to_s
log "Index	Survey ID	Filename"

if $files==false
	doc = REXML::Document.new('<?xml version="1.0" encoding="UTF-8"?>')
	comment = REXML::Comment.new(" XML file generated by InfoAsset Manager #{v} (http://www.innovyze.com)")
	doc.add(comment)
	project = doc.add_element("PROJECT")
	filename=$exportLoc+$filenamePrefix+'.xml'#SecureRandom.uuid+'_0'+'.xml'
	project.add_element("PROJECTID").text = SecureRandom.uuid
	project.add_element("SOFTWAREVENDOR").text = "InfoAsset Manager from Innovyze, an Autodesk company"
	project.add_element("SOFTWAREVERSION").text = v.to_s
	project.add_element("NAME").text = (o.project.empty?) ? $projectID : o.project
	project.add_element("COMMENTS").text = ""
	project.add_element("CREATED").text = currtime
	project.add_element("CREATEDBY").text = Etc.getlogin
	project.add_element("MODIFIED").text = currtime
	project.add_element("MODIFIEDBY").text = Etc.getlogin
	surveys = project.add_element("SURVEYS")
end

c=0
while c<n
	list.each do |o|
		nw.clear_selection
		ro=nw.row_object('cams_cctv_survey',o.id)
		ro.selected=true

		if $files==true
			doc = REXML::Document.new('<?xml version="1.0" encoding="UTF-8"?>')
			comment = REXML::Comment.new(" XML file generated by InfoAsset Manager #{v} (http://www.innovyze.com)")
			doc.add(comment)
			project = doc.add_element("PROJECT")
			filename=$exportLoc+$filenamePrefix+c.to_s+'.xml'#uuid+'_0'+'.xml'
			project.add_element("PROJECTID").text = SecureRandom.uuid
			project.add_element("SOFTWAREVENDOR").text = "InfoAsset Manager from Innovyze, an Autodesk company"
			project.add_element("SOFTWAREVERSION").text = v.to_s
			project.add_element("NAME").text = (o.project.empty?) ? $projectID : o.project
			project.add_element("COMMENTS").text = ($comments.empty?) ? nil : $comments
			project.add_element("CREATED").text = currtime
			project.add_element("CREATEDBY").text = Etc.getlogin
			project.add_element("MODIFIED").text = currtime
			project.add_element("MODIFIEDBY").text = Etc.getlogin
			surveys = project.add_element("SURVEYS")
		end

		log "#{c}	#{o.id}	#{filename}"


		survey = surveys.add_element("SURVEY")
		survey.add_element("SURVEYID").text = o.id
		header = survey.add_element("HEADER")
			## 2.6.2 HEADER CODES TO DESCRIBE THE LOCATION OF THE INSPECTION
		header.add_element("AAA").text = (o.plr.empty?) ? nil : o.plr				##Conduit reference
		header.add_element("AAB").text = (o.start_manhole.empty?) ? nil : o.start_manhole				##Start node reference
		header.add_element("AAC").text = (o.us_x.nil?) || (o.us_y.nil?) ? nil : o.us_x.to_s+' '+o.us_y.to_s				##Start node coordinates
		header.add_element("AAF").text = (o.finish_manhole.empty?) ? nil : o.finish_manhole				##Finish node reference
		header.add_element("AAG").text = (o.ds_x.nil?) || (o.ds_y.nil?) ? nil : o.ds_x.to_s+' '+o.ds_y.to_s				##Finish node coordinates
		header.add_element("AAH").text = (o.long_location.nil?) ? nil : o.long_location				##Longitudinal location of start of lateral
		header.add_element("AAI").text = (o.lateral_clock_loc.empty?) ? nil : o.lateral_clock_loc				##Circumferential location of start of lateral
		header.add_element("AAJ").text = (o.road_name.empty?) ? nil : o.road_name				##Location
		header.add_element("AAK").text = (o.direction.empty?) ? nil : o.direction				##Direction of inspection
		header.add_element("AAL").text = (o.location.empty?) ? nil : o.location				##Location type
		header.add_element("AAM").text = (o.owner.empty?) ? nil : o.owner				##Asset owner or engaging agency
		header.add_element("AAN").text = (o.place_name.empty?) ? nil : o.place_name				##Town or suburb
		header.add_element("AAO").text = (o.district.empty?) ? nil : o.district				##District
		header.add_element("AAP").text = (o.catchment.empty?) ? nil : o.catchment				##Name of conduit system
		header.add_element("AAQ").text = (o.division.empty?) ? nil : o.division				##Land ownership
		header.add_element("AAR").text = (o.coordinate_system.empty?) ? nil : o.coordinate_system				##Mapping grid datum system
		#header.add_element("AAS").text = (o.FIELD.empty?) ? nil : o.FIELD				##"Mapping grid zone - Record the appropriate grid zone for coordinates"

			## 2.6.3 HEADER CODES FOR REPORTING INSPECTION DETAILS
		header.add_element("ABA").text = (o.standard.empty?) ? nil : o.standard				##Standard
		header.add_element("ABB").text = (o.scoring_method.empty?) ? nil : o.scoring_method				##Original coding standard
		header.add_element("ABC").text = (o.longitudinal_reference_point.empty?) ? nil : o.longitudinal_reference_point				##Longitudinal reference point
		header.add_element("ABD").text = (o.location_risk_factor.empty?) ? nil : o.location_risk_factor				##Conduit location risk factor observed by operator
		header.add_element("ABE").text = (o.method.empty?) ? nil : o.method				##Method of inspection
		header.add_element("ABF").text = (o.when_surveyed.nil? || o.when_surveyed == 0) ? nil : o.when_surveyed.strftime("%d-%m-%Y")				##Date of inspection
		header.add_element("ABG").text = (o.when_surveyed.nil? || o.when_surveyed == 0) ? nil : o.when_surveyed.strftime("%H:%M")				##Time of inspection
		header.add_element("ABH").text = (o.surveyed_by.empty?) ? nil : o.surveyed_by				##Operator
		header.add_element("ABI").text = (o.job_number.empty?) ? nil : o.job_number				##Inspection company's job reference
		header.add_element("ABJ").text = (o.contract_no.empty?) ? nil : o.contract_no				##Asset owner's job reference
		header.add_element("ABL").text = (o.reviewed_by.empty?) ? nil : o.reviewed_by				##Coder/Assessor
		header.add_element("ABM").text = (o.video_recorder.empty?) ? nil : o.video_recorder				##Video image location system
		#header.add_element("ABN").text = (o.FIELD.empty?) ? nil : o.FIELD				##Evidence of surcharge in start node
		header.add_element("ABP").text = (o.purpose.empty?) ? nil : o.purpose				##Purpose of inspection
		header.add_element("ABQ").text = (o.anticipated_length.nil?) ? nil : o.anticipated_length				##Anticipated length of inspection
		header.add_element("ABR").text = (o.surveyed_length.nil?) ? nil : o.surveyed_length				##Actual inspection length
		header.add_element("ABS").text = (o.contractor.empty?) ? nil : o.contractor				##Name of company responsible for inspection

			##2.6.4 HEADER CODES FOR RECORDING CONDUIT DETAILS
		header.add_element("ACA").text = (o.shape.empty?) ? nil : o.shape				##Shape
		header.add_element("ACB").text = (o.size_1.nil?) ? nil : o.size_1				##Height
		header.add_element("ACC").text = (o.size_2.nil?) ? nil : o.size_2				##Width
		header.add_element("ACD").text = (o.material.empty?) ? nil : o.material				##Material
		header.add_element("ACE").text = (o.lining_type.empty?) ? nil : o.lining_type				##Lining type
		header.add_element("ACF").text = (o.lining.empty?) ? nil : o.lining				##Lining material
		header.add_element("ACG").text = (o.pipe_unit_length.nil?) ? nil : o.pipe_unit_length				##Conduit unit length
		header.add_element("ACH").text = (o.start_depth.nil?) ? nil : o.start_depth				##Depth at start node
		header.add_element("ACI").text = (o.finish_depth.nil?) ? nil : o.finish_depth				##Depth at finish node
		header.add_element("ACJ").text = (o.pipe_type.empty?) ? nil : o.pipe_type				##Operation of conduit
		header.add_element("ACK").text = (o.use.empty?) ? nil : o.use				##Use of conduit
		header.add_element("ACL").text = (o.strategic.empty?) ? nil : o.strategic				##Criticality
		header.add_element("ACM").text = (o.preclean_choice.empty?) ? nil : o.preclean_choice				##Cleaning
		header.add_element("ACN").text = (o.year_laid.empty?) ? nil : o.year_laid				##Year came into operation
		header.add_element("ACO").text = (o.jointing_method.empty?) ? nil : o.jointing_method				##Jointing method
		header.add_element("ADA").text = (o.weather.empty?) ? nil : o.weather				##Precipitation
		header.add_element("ADB").text = (o.temperature.empty?) ? nil : o.temperature				##Temperature
		header.add_element("ADC").text = (o.flow_control.empty?) ? nil : o.flow_control				##Flow control measures
		header.add_element("ADD").text = (o.tidal_influence.empty?) ? nil : o.tidal_influence				##Tidal influence
		header.add_element("ADE").text = (o.comments.empty?) ? nil : o.comments				##General comment

			##2.6.6 USER DEFINABLE HEADER CODES
		# header.add_element("AEA").text = (o.FIELD.empty?) ? nil : o.FIELD				##User defined
		# header.add_element("AEB").text = (o.FIELD.empty?) ? nil : o.FIELD				##User defined
		# header.add_element("AEC").text = (o.FIELD.empty?) ? nil : o.FIELD				##User defined
		# header.add_element("AED").text = (o.FIELD.empty?) ? nil : o.FIELD				##User defined
		# header.add_element("AEE").text = (o.FIELD.empty?) ? nil : o.FIELD				##User defined

			##2.6.7 HEADER CODES FOR STRUCTURAL AND SERVICE CONDITION STATISTICS
		# header.add_element("AFA").text = (o.hard_wired_structural_grade.nil?) ? nil : o.hard_wired_structural_grade				##Structural grade
		# #header.add_element("AFB").text = (o.FIELD.nil?) ? nil : o.FIELD				##Number of structural defects
		# header.add_element("AFC").text = (o.peak_score.nil?) ? nil : o.peak_score				##Structural peak score
		# header.add_element("AFD").text = (o.mean_score.nil?) ? nil : o.mean_score				##Structural mean score
		# header.add_element("AFE").text = (o.hard_wired_service_grade.nil?) ? nil : o.hard_wired_service_grade				##Service grade
		# #header.add_element("AFF").text = (o.FIELD.nil?) ? nil : o.FIELD				##Number of service defects
		# header.add_element("AFG").text = (o.service_peak_score.nil?) ? nil : o.service_peak_score				##Service peak score
		# header.add_element("AFH").text = (o.service_mean_score.nil?) ? nil : o.service_mean_score				##Service mean score

			##2.7 CODES FOR REPORTING THE INSPECTION OF CONDUITS
		details=o.details
		obsImages=Array.new
		obsVideos=Array.new
		if details.size>0
			observations = survey.add_element("OBSERVATIONS")
			details=o.details
			details.each do |d|
				observation = observations.add_element("OBSERVATION")
				obid=SecureRandom.uuid
				observation.add_element("OBSERVATIONID").text = obid
				observation.add_element("CHAINAGE").text = (d.distance.nil?) ? nil : d.distance
				observation.add_element("CODE").text = (d.code.empty?) ? nil : d.code
				observation.add_element("CHAR1").text = (d.characterisation1.empty?) ? nil : d.characterisation1
				observation.add_element("CHAR2").text = (d.characterisation2.empty?) ? nil : d.characterisation2
				observation.add_element("QUANT1").text = (d.diameter.nil?) ? nil : d.diameter
				observation.add_element("QUANT2").text = (d.intrusion.nil?) ? nil : d.intrusion
				observation.add_element("CLOCK1").text = (d.clock_at.nil?) ? nil : d.clock_at
				observation.add_element("CLOCK2").text = (d.clock_to.nil?) ? nil : d.clock_to
				observation.add_element("REMARK").text = (d.remarks.empty?) ? nil : d.remarks
				observation.add_element("JOINT").text = (d.joint==false) ? nil : "J"
				observation.add_element("CONTINUOUS").text = (d.cd.empty?) ? nil : d.cd
				observation.add_element("STR").text = (d.structural_score.nil?) ? nil : d.structural_score
				observation.add_element("SER").text = (d.service_score.nil?) ? nil : d.service_score
				observation.add_element("VIDEOPOSITION").text = (d.video_no2.empty?) ? nil : d.video_no2
				#observation.add_element("TEXT").text = (d.FIELD.empty?) ? nil : d.FIELD
				unless d.detail_image.nil? || d.detail_image.empty?
					obsImages << [obid, d.detail_image]
				end
				unless d.video_file.nil? || d.video_file.empty?
					obsVideos << [obid, d.video_file]
				end
			end
		else
			observations = survey.add_element("OBSERVATIONS")
		end
#log obsImages
#log obsVideos
			##A5.1.5 <SCORES />
		scores = survey.add_element("SCORES")
		# #scores.add_element("SERAVG").text = (o.FIELD.nil?) ? nil : o.FIELD
		# scores.add_element("SERGRADE").text = (o.hard_wired_service_grade.nil?) ? nil : o.hard_wired_service_grade
		# scores.add_element("SERMEAN").text = (o.service_mean_score.nil?) ? nil : o.service_mean_score
		# #scores.add_element("SERNUM").text = (o.FIELD.nil?) ? nil : o.FIELD
		# scores.add_element("SERPEAK").text = (o.service_peak_score.nil?) ? nil : o.service_peak_score
		# scores.add_element("SERTOTAL").text = (o.service_total_score.nil?) ? nil : o.service_total_score
		# #scores.add_element("STRAVG").text = (o.FIELD.nil?) ? nil : o.FIELD
		# scores.add_element("STRGRADE").text = (o.hard_wired_structural_grade.nil?) ? nil : o.hard_wired_structural_grade
		# scores.add_element("STRMEAN").text = (o.mean_score.nil?) ? nil : o.mean_score
		# #scores.add_element("STRNUM").text = (o.FIELD.nil?) ? nil : o.FIELD
		# scores.add_element("STRPEAK").text = (o.peak_score.nil?) ? nil : o.peak_score
		# scores.add_element("STRTOTAL").text = (o.total_score.nil?) ? nil : o.total_score


			##A5.1.7 <VIDEO />
		unless obsVideos.size==0 && (o.video_file_in.nil? || o.video_file_in.empty?)
			videos = survey.add_element("VIDEOS")
			unless o.video_file_in.nil? || o.video_file_in.empty?
				video = videos.add_element("VIDEO")
				video.add_element("FILENAME").text = (o.video_file_in.empty?) ? nil : o.video_file_in
				video.add_element("OBSERVATIONID").text = nil
			end
			unless obsVideos.size==0
				(0...obsVideos.size).each do |i|
				video = videos.add_element("VIDEO")
					log "VIDEOS: #{obsVideos[i]}"
					video.add_element("FILENAME").text =obsVideos[i][1]
					video.add_element("OBSERVATIONID").text =obsVideos[i][0]
				end
			end
		else
			videos = survey.add_element("VIDEOS")
		end


			##A5.1.6 <IMAGE />
		if obsImages.size>0
			images = survey.add_element("IMAGES")
			(0...obsImages.size).each do |i|
			image = images.add_element("IMAGE")
				log "IMAGES: #{obsImages[i]}"
				image.add_element("FILENAME").text =obsImages[i][1]
				image.add_element("OBSERVATIONID").text =obsImages[i][0]
			end
		else
		images = survey.add_element("IMAGES")
		end

		laser = survey.add_element("LASER")
		scan = survey.add_element("SCAN")
		ext = survey.add_element("EXT")

		if $files==true
			File.open(filename, "w") do |file|
				doc.write(file)#, 1, false)
			end
		end
		c=c+1
	end
end
	if $files==false
		File.open(filename, "w") do |file|
			doc.write(file)#, 1, false)
		end
	end



endingTime = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = endingTime - startingTime

log
log "Done.  Time taken #{Time.at(elapsed).utc.strftime("%H:%M:%S")}"
log

$logFile.close()
