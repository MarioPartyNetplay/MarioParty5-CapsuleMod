import struct
import argparse

# Set up argument parsing
parser = argparse.ArgumentParser(description='Convert a.out to Gecko format.')
parser.add_argument('input_file', type=str, help='Input a.out file')
parser.add_argument('start_address', type=str, help='Starting address in hexadecimal')
parser.add_argument('output_file', type=str, help='Output file for the Gecko code')

args = parser.parse_args()

# Read the a.out file
with open(args.input_file, 'rb') as f:
    data = f.read()

# Extract relevant data
data = data[52:data.index(b'\x00\x2E\x73\x79\x6D\x74\x61\x62')]  # Adjusted for Python

# Calculate the number of lines
num_lines = (len(data) + 7) // 8  # Calculate number of lines (rounding up) and add 1 for the final line

# Prepare the output code
code = []

# Ensure start_address is a string before conversion
start_address_int = int(str(args.start_address), 16) & 0xFFFFFFFF  # Convert and format the starting address

# Swap the first two bytes if necessary
first_byte = (start_address_int >> 24) & 0xFF  # Get the first byte
if first_byte == 0x80:
    start_address_int = (start_address_int & ~0xFF000000) | (0xC2 << 24)  # Swap 80 to C2
elif first_byte == 0x81:
    start_address_int = (start_address_int & ~0xFF000000) | (0xD2 << 24)  # Swap 81 to D2


# Prepare the output code with spacing
counter = 0
for b in data:
    if counter % 8 == 0 and counter != 0:
        code.append("\n")  # New line after every 8 bytes

    if counter % 4 == 0 and counter % 8 != 0 and counter != 0:
        code.append(" ")  # Add space after every 4 bytes

    code.append(f"{b:02X}")  # Append the byte in hex format
    counter += 1

# Add padding if necessary
if counter % 8 != 0:
    code.append(" 00000000")  # Add padding if not a multiple of 8

# Calculate the number of lines
num_lines = (len(data) + 7) // 8  # Calculate number of lines (rounding up) and add 1 for the final line

# Add the initial line with the starting address and number of lines
code.insert(0, f"{start_address_int:08X} {num_lines:08X}\n")  # Insert at the beginning

# Only add the final line if the total bytes complete a full line of 8 bytes
if len(data) % 8 == 0:
    code.append("\n60000000 00000000")  # Final line only if complete
    num_lines = num_lines + 1  # Calculate number of lines (rounding up) and add 1 for the final line

# Join the code into a single string
formatted_code = ''.join(code)

# Write to dist/code.txt
with open(args.output_file, "w") as output_file:
    output_file.write(formatted_code)
