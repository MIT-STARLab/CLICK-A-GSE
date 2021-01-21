prompt("Press OK to continue")

x = ask("Enter an integer: ")
puts x

value = message_box("Select the sensor number", 'One', 'Two')
value = vertical_message_box("Select the sensor number", 'One', 'Two')
value = combo_box("Select the sensor number", 'One', 'Two')
case value
when 'One'
  puts 'Sensor One'
when 'Two'
  puts 'Sensor Two'
end

selected_file = open_file_dialog()
file_data = ""
File.open(selected_file, 'rb') {|file| file_data = file.read()}

# Filter will initially show only .txt files, but can be changed to show all files...
selected_file = open_file_dialog(Cosmos::USERPATH, "Open File", "Text (*.txt);;All (*.*)")
