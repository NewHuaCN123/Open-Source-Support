# Define database fields for an ICM network node
database_fields = [
  "X",
  "Y",
  "ground_level",
  "flood level"
]

begin
  net = WSApplication.current_network
  net.clear_selection

  # Prepare hash for storing data of each field
  fields_data = {}
  database_fields.each { |field| fields_data[field] = [] }

  # Initialize the count of processed rows
  row_count = 0

  # Collect data for each field
  net.row_objects('hw_node').each do |ro|
    row_count += 1
    database_fields.each do |field|
      fields_data[field] << ro[field] if ro[field]
    end
  end

  # Print min, max, mean, standard deviation, total, and row count for each field
  database_fields.each do |field|
    data = fields_data[field]
    
    if data.empty?
      puts "#{field} has no data!"
      next
    end
    
    min_value = data.min
    max_value = data.max
    sum = data.inject(0.0) { |sum, val| sum + val }
    mean_value = sum / data.size
    # Calculate the standard deviation
    sum_of_squares = data.inject(0.0) { |accum, i| accum + (i - mean_value) ** 2 }
    standard_deviation = Math.sqrt(sum_of_squares / data.size)
    total_value = sum

    # Updated printf statement with row count
    printf("%-30s | Row Count: %-10d | Min: %-10.3f | Max: %-10.3f | Mean: %-10.3f | Std Dev: %-10.2f | Total: %-10.2f\n", 
           field, row_count, min_value, max_value, mean_value, standard_deviation, total_value)
  end

rescue => e
  # Include the field name and number of processed rows in the error message
  puts "An error occurred with the field '#{field}' after processing #{row_count} rows: #{e.message}"
end
