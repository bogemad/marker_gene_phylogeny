#!/usr/bin/env python

import sys, os, re, shutil, decimal, subprocess
from Bio import SeqIO

def generate_aln(base_path, limit, cleaned_alignment_path, ditched_outfile):
	records = []
	ditched_records = []
	print("Generating alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
	try:
		print("Removing sequences with greater than {0:.1f}% gaps...".format(limit*100))
		for item in os.listdir(os.path.join(base_path,'raw_data','PS_temp')):
			record = SeqIO.read(os.path.join(base_path, 'raw_data', 'PS_temp', item, 'alignDir', 'concat.codon.updated.1.fasta'), 'fasta')
			record.id = re.sub(r'\.1\..*','',record.id)
			record.name = ''
			record.description = ''
			if sum(1 for x in record.seq if x == '-')/len(record) < limit:
				records.append(record)
			else:
				ditched_records.append(record)
	except Exception as e:
		print(str(e))
		print("Failed to remove sequence {} from alignment. Check the file name for illegal characters.".format(item))
		raise
	null = SeqIO.write(records, cleaned_alignment_path, 'fasta')
	null = SeqIO.write(ditched_records, ditched_outfile, 'fasta')
	return records, ditched_records

def trim_aln(limit, cleaned_alignment_path, trimmed_alignment_path):
	try:
		print("Triming alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
		subprocess.run(["trimal", "-in", cleaned_alignment_path, "-out", trimmed_alignment_path, "-nogaps"], check=True)
	except Exception as e:
		print(str(e))
		print("Failed triming alignment with sequences greater than {0:.1f}% gaps removed.".format(limit*100))

def check_trim(limit, cleaned_alignment_path, trimmed_alignment_path, trimming_report_path, total_sequences):
	try:
		print("Checking trimmed alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
		subprocess.run(["check_trim", trimmed_alignment_path, cleaned_alignment_path, trimming_report_path, str(total_sequences)], check=True)
	except Exception as e:
		print(str(e))
		print("Failed checking trimmed alignment with sequences greater than {0:.1f}% gaps removed.".format(limit*100))

def build_tree(limit, trimmed_alignment_path, phylosift_tree_path):
	try:
		print("Building tree from alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
		with open(trimmed_alignment_path, 'rb') as trimmed_alignment, open(phylosift_tree_path,'wb') as phylosift_tree:
			subprocess.run(["FastTree", "-nt", "-gtr"], check=True, stdin=trimmed_alignment, stdout=phylosift_tree)
	except Exception as e:
		print(str(e))
		print("Failed building tree from  alignment with sequences greater than {0:.1f}% gaps removed.".format(limit*100))

def generate_trimming_summary(base_path, limits):
	data_d = {}
	for limit in limits:
		limit = float(limit)
		if limit == 1.0:
			outdir = os.path.join(base_path, 'analysis_results', 'raw')
		else:
			outdir = os.path.join(base_path, 'analysis_results', 'gt_%.1f_percent_gaps_removed' % (limit*100))
		trimming_report_path = os.path.join(outdir, "trimming_report.txt")
		if os.path.isfile(trimming_report_path):
			with open(trimming_report_path) as trimming_report:
				trim_data = trimming_report.readlines()
			data_d[limit] = [trim_data[0].strip()[36:], trim_data[1].strip()[49:], trim_data[2].strip()[32:], trim_data[3].strip()[30:], trim_data[4].strip()[36:]]

	trimming_summary_path = os.path.join(base_path, 'analysis_results', "trimming_summary.txt")
	with open(trimming_summary_path, 'w') as trimming_summary:
		trimming_summary.write("Gap threshold\t# sequences in raw alignment\t# sequences with less gaps than limit\tLength of untrimmed alignment\tLength of trimmed alignment\tPercent bases removed by trimming\n")
		for limit in sorted(list(data_d)):
			if limit == 1.0:
				trimming_summary.write("raw\t{0}\t{1}\t{2}\t{3}\t{4}\n".format(data_d[limit][0],data_d[limit][1],data_d[limit][2],data_d[limit][3],data_d[limit][4]))
			else:
				trimming_summary.write("{0:.2f}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(limit, data_d[limit][0],data_d[limit][1],data_d[limit][2],data_d[limit][3],data_d[limit][4]))

def main():
	base_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
	if len(sys.argv) == 2:
		limit = float(sys.argv[1])
		if limit == 1.0:
			outdir = os.path.join(base_path, 'analysis_results', 'raw')
			phylosift_tree_path = os.path.join(outdir,'phylosift_raw.tre')
		else:
			outdir = os.path.join(base_path, 'analysis_results', 'gt_%.1f_percent_gaps_removed' % (limit*100))
			phylosift_tree_path = os.path.join(outdir,'phylosift_gt_%.1f_percent_gaps_removed.tre' % (limit*100))
		cleaned_alignment_path = os.path.join(outdir, "cleaned_alignment.fa")
		trimmed_alignment_path = os.path.join(outdir, "trimmed_alignment.fa")
		trimming_report_path = os.path.join(outdir, "trimming_report.txt")
		ditched_outfile = os.path.join(outdir,'ditched_sequences.fa')
		if os.path.isdir(outdir):
			shutil.rmtree(outdir)
		os.mkdir(outdir)
		records, ditched_records = generate_aln(base_path, limit, cleaned_alignment_path, ditched_outfile)
		if len(records) < 3:
			print("All or almost all sequences are greater than %.1f gaps, please retry with a higher gap threshold" % limit)
			sys.exit(0)
		trim_aln(limit, cleaned_alignment_path, trimmed_alignment_path)
		check_trim(limit, cleaned_alignment_path, trimmed_alignment_path, trimming_report_path, (len(records)+len(ditched_records)))
		build_tree(limit, trimmed_alignment_path, phylosift_tree_path)
	else:
		limits = sys.argv[1:]
		generate_trimming_summary(base_path, limits)


if __name__ == '__main__':
	main()
