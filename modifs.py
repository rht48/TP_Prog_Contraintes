import sys
args = sys.argv

if len(args) >= 2:
    file_path = args[1]
    file = open(file_path, "r")
    new_file_content = ""
    for line in file:
        if line.startswith(">"):
            new_file_content += line.replace("[", "\[").replace("]", "\]")
        else:
            new_file_content += line
        new_file_content += "\n"
        
    file.close()    

    new_file = open(file_path, "w")
    new_file.write(new_file_content)
    new_file.close()
