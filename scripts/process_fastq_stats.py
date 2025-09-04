import csv
import os
import sys

def get_fastq_stats(fastq_file):
    total_sequences = 0
    max_length = 0
    min_length = float('inf')

    with open(fastq_file, 'r') as f:
        while True:
            header = f.readline().strip()
            if not header:
                break
            sequence = f.readline().strip()
            plus_line = f.readline().strip()
            quality = f.readline().strip()
            
            seq_length = len(sequence)
            total_sequences += 1
            if seq_length > max_length:
                max_length = seq_length
            if seq_length < min_length:
                min_length = seq_length

    return total_sequences, max_length, min_length

def process_csv(csv_file, fastq_dir):
    with open(csv_file, 'r') as f:
        reader = csv.reader(f)
        data = list(reader)

    headers = data[0]
    headers.extend(["Total Sequences", "Max Length", "Min Length"])

    for row in data[1:]:
        fastq_file = os.path.join(fastq_dir, row[0])
        total_sequences, max_length, min_length = get_fastq_stats(fastq_file)
        row.extend([total_sequences, max_length, min_length])

    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(data[1:])

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 script.py <csv_file> <fastq_directory>")
        sys.exit(1)

    csv_file = sys.argv[1]
    fastq_dir = sys.argv[2]

    process_csv(csv_file, fastq_dir)
