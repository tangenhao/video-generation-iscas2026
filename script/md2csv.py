import pandas as pd
import argparse

# Args parser
parser = argparse.ArgumentParser(description='Convert Markdown to Excel')
parser.add_argument('--input', 
                    type=str, 
                    required=True,
                    help='Markdown file path, required')
parser.add_argument('--output',
                    type=str,
                    required=False,
                    help='Excel file path, optional, default is the same as the input file path with .xlsx extension')

if __name__ == '__main__':
    args = parser.parse_args()
    md_path = args.input
    file_path = args.output if args.output else md_path.split('.')[-2] + ".csv"
    assert "csv" in file_path, "Output file must be a .xlsx file"
    
    # Read the markdown file
    with open(md_path, 'r') as f:
        markdown_data = f.read()
    
    # Convert the markdown data to a pandas DataFrame
    title = markdown_data.split('\n')[0].split('|')[1:-1]
    
    data = []
    for line in markdown_data.split('\n')[2:]:
        if line:
            data.append(line.split('|')[1:-1])
            
    markdown_table = pd.DataFrame(data, columns=title)
    
    # Save the DataFrame to an csv file
    markdown_table.to_csv(file_path, index=False)
    