module Adebeo::DanielTall_GEMaker
	class KmzMaker
		attr_accessor
		def initialize()
			@model = Sketchup.active_model
			@options = Adebeo::ExtensionName::getUserOptions()

			#get gm terrain
			allgroup = @model.entities.grep(Sketchup::Group)
			googlemapGroups = allgroup.select{|a| a.name == "Location Snapshot"}
			googlemapGroup = googlemapGroups.first
			facesOfGoogleMap = googlemapGroup.entities.grep(Sketchup::Face)
			faceOfGoogleMap = facesOfGoogleMap.first
			vertexOfGoogleMap = faceOfGoogleMap.vertices
			ptOfGoogleMap = [Geom::Point3d.new(0, 0, 0)]
			vertexOfGoogleMap.each{|vertex| ptOfGoogleMap.push(vertex.position)}

			# convert to utm
			utmPoints = []
			latLongPoints = []
			ptOfGoogleMap.each{|pt| 
				utmPoints.push(@model.point_to_utm(pt))
				ll = @model.point_to_latlong(pt)
				latLongPoints.push(Geom::LatLong.new([ll.x,ll.y]))
			}
			#get altitude
			view = @model.active_view
			camera = Sketchup::Camera.new [0,0,2000], [0,0,0], [0,1,0]
			view.camera = camera
			camera.perspective = true
			camera.fov = 10
			view.zoom_extents
			altitude = view.camera.eye.z.to_f*0.0254
			#create kml
			allMaker = ""
			first = true
			kmltxt = ""
			latLongPoints.each{|llpt|
				if first
					name = "center"
					visibility = 0
					first = false
				else
					name = ""
					visibility = 1
				end

				allMaker += createMarker({
					:long=>llpt.latitude,
					:lat=>llpt.longitude,
					:alt=>altitude,
					:name=>name,
					:visibility=>visibility
				})
				if name == "center"
					kmltxt = defautkml({
						:long=>llpt.latitude,
						:lat=>llpt.longitude,
						:alt=>altitude,
						:name=>name
					})
				end
			}
			#wrote kml
			kmltxt.gsub!("#MAKER",allMaker)

		    filePath=@model.path
		    if filePath == ""
		      UI.messagebox("You must save the 'Untitled' new model.")
		      return nil
		    end
		    filePath.gsub!("skp","kml")
		    file=File.new(filePath,"w")
		    file.puts(kmltxt)
		    file.close
		    UI.messagebox("kml save to #{filePath}.")	

		end

		def createMarker(spec)
			@spec = {
				:long=>4.834983979474814,
				:lat=>45.76372837536355,
				:alt=>1726.000370805841,
				:name=>"defaut"
			}

			spec.each{|k,v| @spec[k]= v}

			strandarMarker = "<Placemark>
					<name>#{@spec[:name]}</name>
					<LookAt>
						<longitude>#{@spec[:long]}</longitude>
						<latitude>#{@spec[:lat]}</latitude>
						<altitude>0</altitude>
						<heading>0</heading>
						<tilt>0</tilt>
						<range>#{@spec[:alt]}</range>
						<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
					</LookAt>
					<styleUrl>#msn_placemark_circle</styleUrl>
					<Point>
						<gx:drawOrder>1</gx:drawOrder>
						<coordinates>#{@spec[:long]},#{@spec[:lat]}</coordinates>
					</Point>
					<visibility>#{@spec[:visibility]}</visibility>
				</Placemark>"
			return strandarMarker
		end

		def defautkml(center)
			lookat = "<LookAt>
				<longitude>#{center[:long]}</longitude>
				<latitude>#{center[:lat]}</latitude>
				<altitude>0</altitude>
				<heading>-0.0002069916018148742</heading>
				<tilt>0</tilt>
				<range>#{center[:alt]}</range>
				<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
			</LookAt>"

			defautkml = '<?xml version="1.0" encoding="UTF-8"?>
		<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
		<Document>
			<name>adebeo_daniel_tall_maker.kml</name>
			#LOOKAT
			<Style id="sn_placemark_circle">
				<IconStyle>
					<scale>1.2</scale>
					<Icon>
						<href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href>
					</Icon>
				</IconStyle>
				<ListStyle>
				</ListStyle>
			</Style>
			<StyleMap id="msn_placemark_circle">
				<Pair>
					<key>normal</key>
					<styleUrl>#sn_placemark_circle</styleUrl>
				</Pair>
				<Pair>
					<key>highlight</key>
					<styleUrl>#sh_placemark_circle_highlight</styleUrl>
				</Pair>
			</StyleMap>
			<Style id="sh_placemark_circle_highlight">
				<IconStyle>
					<scale>1.2</scale>
					<Icon>
						<href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle_highlight.png</href>
					</Icon>
				</IconStyle>
				<ListStyle>
				</ListStyle>
			</Style>
			<Folder>
				<name>adebeo_daniel_tall_maker</name>
				<open>1</open>
				#MAKER
			</Folder>
		</Document>
		</kml>'

		defautkml.gsub!("#LOOKAT",lookat)

		return defautkml
		end
	end
end