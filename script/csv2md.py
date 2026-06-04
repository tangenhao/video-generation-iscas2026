import argparse
import pandas as pd

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


if __name__ == "__main__":
    args = parser.parse_args()
    file_path = args.input
    md_path = args.output if args.output else file_path.split('.')[0] + ".md"
    
    # Read the csv file
    csv_data = pd.read_csv(file_path)
    
    # Convert the csv data to a markdown file
    # Get the title and data from the csv data
    title_csv = csv_data.columns.values.tolist()
    # Get the data from the csv data
    data_csv = csv_data.values.tolist()
    # Create the markdown title string
    md_title = "| " + " | ".join(title_csv) + " |"
    # Create the markdown separator string
    md_sep = "| " + " | ".join(["---" for _ in title_csv]) + " |"
    # Create the markdown data string
    md_data = ""
    for row in data_csv:
        md_data += "| " + " | ".join([str(cell) for cell in row]) + " |\n"

    # Save the markdown data to a file
    with open(md_path, 'w') as f:
        f.write(md_title + "\n")
        f.write(md_sep + "\n")
        f.write(md_data)