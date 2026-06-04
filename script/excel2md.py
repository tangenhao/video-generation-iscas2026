import xml.dom.minidom
import zipfile
import os
import shutil
import argparse

# Args parser
parser = argparse.ArgumentParser(description='Convert Excel to Markdown')
parser.add_argument('--input', 
                    type=str, 
                    required=True,
                    help='Excel file path, must be a .xlsx file, required')
parser.add_argument('--output', 
                    type=str,
                    required=False,
                    help='Markdown file path, optional, default is the same as the input file path with .md extension')
parser.add_argument('--temp',
                    type=str,
                    required=False,
                    help='Temporary folder path, optional, default is the same as the input file path with _temp suffix')

if __name__ == '__main__':
    args = parser.parse_args()
    file_path = args.input
    md_path = args.output if args.output else file_path.split('.')[0] + ".md"
    output_path = args.temp if args.temp else file_path.split('.')[0] + "_temp"

    # Unzip the Excel file
    with zipfile.ZipFile(file_path, 'r') as zip_ref:
        zip_ref.extractall(output_path)

    strings = []

    # Read shared strings
    shared_strings_path = os.path.join(output_path, "xl/sharedStrings.xml")
    if os.path.exists(shared_strings_path):
        with open(shared_strings_path, 'r') as data:
            # Convert the sharedStrings.xml file to a DOM object
            dom = xml.dom.minidom.parse(data)
            # Find all t tags
            for string in dom.getElementsByTagName('t'):
                # Add the value of the t tag to the strings list
                strings.append(string.childNodes[0].nodeValue)

    result = []

    # Read sheet data
    sheet_path = os.path.join(output_path, "xl/worksheets/sheet1.xml")
    if os.path.exists(sheet_path):
        with open(sheet_path, 'r') as data:
            dom = xml.dom.minidom.parse(data)
            # Iterate over each row tag
            for row in dom.getElementsByTagName('row'):
                row_data = []
                # Iterate over each c tag
                for cell in row.getElementsByTagName('c'):
                    value = ''
                    # If the cell has a t attribute, it means it is a shared string
                    if cell.getAttribute('t') == 's':
                        shared_string_index = int(cell.getElementsByTagName('v')[0].childNodes[0].nodeValue)
                        value = strings[shared_string_index]
                    # Otherwise, it is a normal value
                    else:
                        value = cell.getElementsByTagName('v')[0].childNodes[0].nodeValue
                    # Append the value to the row_data list
                    row_data.append(value)
                # Append the row_data list to the result list
                result.append(row_data)

    # Delete the temporary folder
    shutil.rmtree(output_path)

    # Create the Markdown table
    # Generate the first row
    markdown_table = "|"
    markdown_table += "|".join(result[0]) + "|"
    markdown_table += "\n"
    # Generate the second row
    markdown_table += "|"
    markdown_table += "|".join(["-" for _ in result[0]]) + "|"
    markdown_table += "\n"
    # Generate the rest of the rows
    for row in result[1:]:
        markdown_table += "|"
        markdown_table += "|".join([value for value in row]) + "|"
        markdown_table += "\n"
    # remove the last newline character
    markdown_table = markdown_table[:-1]

    # Write the Markdown table to a file
    with open(md_path, 'w') as md_file:
        md_file.write(markdown_table)