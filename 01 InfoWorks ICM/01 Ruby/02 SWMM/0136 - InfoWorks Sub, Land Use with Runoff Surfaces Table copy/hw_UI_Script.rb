# Initialize the current network
cn = WSApplication.current_network

# Initialize an array to store land use and runoff surface variables
combined_variables = []

# Loop through each land use in the network
cn.row_objects('hw_land_use').each do |land_use|
  # Add the land use variables to the array
  # Each land use is represented as a hash with keys corresponding to variable names and values corresponding to variable values
  land_use_variables = {
    'Land use ID' => land_use.land_use_id,
    'Population density' => land_use.population_density,
    'Wastewater profile' => land_use.wastewater_profile,
    'Connectivity (%)' => land_use.connectivity,
    'Pollution index' => land_use.pollution_index,
    'Description' => land_use.land_use_description,
  }
  
  # Add the runoff surfaces and areas to the land use variables

land_use_variables["Runoff surface #1"] = land_use.runoff_index_1
land_use_variables["Default area #1 (%)"] = land_use.p_area_1
land_use_variables["Runoff surface #2"] = land_use.runoff_index_2
land_use_variables["Default area #2 (%)"] = land_use.p_area_2
land_use_variables["Runoff surface #3"] = land_use.runoff_index_3
land_use_variables["Default area #3 (%)"] = land_use.p_area_3
land_use_variables["Runoff surface #4"] = land_use.runoff_index_4
land_use_variables["Default area #4 (%)"] = land_use.p_area_4
land_use_variables["Runoff surface #5"] = land_use.runoff_index_5
land_use_variables["Default area #5 (%)"] = land_use.p_area_5
land_use_variables["Runoff surface #6"] = land_use.runoff_index_6
land_use_variables["Default area #6 (%)"] = land_use.p_area_6
land_use_variables["Runoff surface #7"] = land_use.runoff_index_7
land_use_variables["Default area #7 (%)"] = land_use.p_area_7
land_use_variables["Runoff surface #8"] = land_use.runoff_index_8
land_use_variables["Default area #8 (%)"] = land_use.p_area_8
land_use_variables["Runoff surface #9"] = land_use.runoff_index_9
land_use_variables["Default area #9 (%)"] = land_use.p_area_9
land_use_variables["Runoff surface #10"] = land_use.runoff_index_10
land_use_variables["Default area #10 (%)"] = land_use.p_area_10
land_use_variables["Runoff surface #11"] = land_use.runoff_index_11
land_use_variables["Default area #11 (%)"] = land_use.p_area_11
land_use_variables["Runoff surface #12"] = land_use.runoff_index_12
land_use_variables["Default area #12 (%)"] = land_use.p_area_12

  combined_variables << land_use_variables

# Loop through each runoff surface in the network
cn.row_objects('hw_runoff_surface').each do |ro|
  # Loop from 1 to 12
  (1..12).each do |i|
    # If the runoff surface is used by the current land use, add its variables to the array
    # Each runoff surface is represented as a hash with keys corresponding to variable names and values corresponding to variable values
    if ro.runoff_index == land_use.send("runoff_index_#{i}")
      runoff_surface_variables = {
        'Runoff surface ID' => ro.runoff_index,
        'Description' => ro.surface_description,
        'Runoff routing type' => ro.runoff_routing_type,
        'Runoff routing value' => ro.runoff_routing_value,
        'Runoff volume type' => ro.runoff_volume_type,
        'Surface type' => ro.surface_type,
        'Ground slope' => ro.ground_slope,
        'Initial loss type' => ro.initial_loss_type,
        'Initial loss value' => ro.initial_loss_value,
        'Initial abstraction factor' => ro.initial_abstraction_factor,
        'Routing model' => ro.routing_model,
        'Fixed runoff coefficient' => ro.runoff_coefficient
      }
      combined_variables << runoff_surface_variables
    end
  end
end
end

combined_variables.each do |variables|
row = variables.values.each_with_index.map { |value, index| index == 5 ? value.to_s[0, 30].ljust(30) : value.to_s[0, 10].ljust(10) }.join(", ")
  
  # Prepend "Land Use" or "Runoff Surface" based on the type of the current row
  if variables.keys.first.start_with?('Land use')
    puts "Land Use       " + row
  elsif variables.keys.first.start_with?('Runoff surface')
    puts "Runoff Surface " + row
  else
    puts row
  end
end

# Initialize the current network
cn = WSApplication.current_network

# Initialize an array to store subcatchment variables
subcatchment_variables = []

# Loop through each subcatchment in the network
cn.row_objects('hw_subcatchment').each do |subcatchment|
  # Add the subcatchment variables to the array
  # Each subcatchment is represented as a hash with keys corresponding to variable names and values corresponding to variable values
  subcatchment_variables << {
    'Subcatchment ID' => subcatchment.subcatchment_id,
    'Land use ID' => subcatchment.land_use_id,
    'Total area' => subcatchment.total_area,
    'Contributed_area' => subcatchment.contributing_area,
    'Area measurement type' => subcatchment.area_measurement_type,
    'Runoff area 1 absolute' => subcatchment.area_absolute_1,
    'Runoff area 2 absolute' => subcatchment.area_absolute_2,
    'Runoff area 3 absolute' => subcatchment.area_absolute_3,
    'Runoff area 4 absolute' => subcatchment.area_absolute_4,
    'Runoff area 5 absolute' => subcatchment.area_absolute_5,
    'Runoff area 6 absolute' => subcatchment.area_absolute_6,
    'Runoff area 7 absolute' => subcatchment.area_absolute_7,
    'Runoff area 8 absolute' => subcatchment.area_absolute_8,
    'Runoff area 9 absolute' => subcatchment.area_absolute_9,
    'Runoff area 10 absolute' => subcatchment.area_absolute_10,
    'Runoff area 11 absolute' => subcatchment.area_absolute_11,
    'Runoff area 12 absolute' => subcatchment.area_absolute_12,
    'Runoff area 1 (%)' => subcatchment.area_percent_1,
    'Runoff area 2 (%)' => subcatchment.area_percent_2,
    'Runoff area 3 (%)' => subcatchment.area_percent_3,
    'Runoff area 4 (%)' => subcatchment.area_percent_4,
    'Runoff area 5 (%)' => subcatchment.area_percent_5,
    'Runoff area 6 (%)' => subcatchment.area_percent_6,
    'Runoff area 7 (%)' => subcatchment.area_percent_7,
    'Runoff area 8 (%)' => subcatchment.area_percent_8,
    'Runoff area 9 (%)' => subcatchment.area_percent_9,
    'Runoff area 10 (%)' => subcatchment.area_percent_10,
    'Runoff area 11 (%)' => subcatchment.area_percent_11,
    'Runoff area 12 (%)' => subcatchment.area_percent_12
  }
end

puts subcatchment_variables.first.keys.each_with_index.map { |key, index| 
key = key.gsub('Runoff ', '').gsub('absolute', '').gsub('area', 'A')
  if index < 1
    key[0, 20].ljust(20)
  else
    key[0, 8].ljust(8)
  end
}.join(", ")

subcatchment_variables.each do |variables|
  row = variables.values.each_with_index.map { |value, index| 
    if index < 1
      value.to_s[0, 20].ljust(20)
    else
      value.to_s[0, 8].ljust(8)
    end
  }.join(", ")
  puts row
end