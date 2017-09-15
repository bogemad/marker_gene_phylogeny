#!/usr/bin/env python

import sys, os, re, shutil, decimal, subprocess
from Bio import SeqIO

base_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

def drange(x, y, jump):
	while x < y:
		yield float(x)
		x = decimal.Decimal(str(x)) + decimal.Decimal(jump)

if len(sys.argv) == 1:
	limits = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1]
elif len(sys.argv) == 4:
	start = float(sys.argv[1])
	end = float(sys.argv[2])
	step = float(sys.argv[3])
	limits = list(drange(start, end, step))



for limit in limits:
	raw_records = []
	records = []
	ditched_records = []
	outdir = os.path.join(base_path, 'analysis_results', 'gt_%.1f_percent_gaps_removed' % (limit*100))
	if os.path.isdir(outdir):
		shutil.rmtree(outdir)
	os.mkdir(outdir)
	cleaned_alignment_path = os.path.join(outdir, "cleaned_alignment_{0:.3f}.fa".format(limit))
	trimmed_alignment_path = os.path.join(outdir, "trimmed_alignment_{0:.3f}.fa".format(limit))
	trimming_report_path = os.path.join(outdir, "trimming_report_{0:.3f}.txt".format(limit))
	print("Generating alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
	try:
		print("Removing sequences with greater than {0:.1f}% gaps...".format(limit*100))
		for item in os.listdir(os.path.join(base_path,'raw_data','PS_temp')):
			# print("Cleaning {}...".format(item))
			record = SeqIO.read(os.path.join(base_path, 'raw_data', 'PS_temp', item, 'alignDir', 'concat.codon.updated.1.fasta'), 'fasta')
			record.id = re.sub(r'\.1\..*','',record.id)
			record.name = ''
			record.description = ''
			raw_records.append(record)
			if sum(1 for x in record.seq if x == '-')/len(record) < limit:
				records.append(record)
			else:
				ditched_records.append(record)
	except Exception as e:
		print(str(e))
		print("Failed to remove sequence {} from alignment. Check the file name for illegal characters.".format(item))
		raise
	outfile = os.path.join(outdir,'cleaned_alignment_%.3f.fa' % limit)
	ditched_outfile = os.path.join(outdir,'ditched_sequences_%.3f.fa' % limit)
	count = SeqIO.write(records,outfile,'fasta')
	count = SeqIO.write(ditched_records,ditched_outfile,'fasta')
	try:
		print("Triming alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
		subprocess.run(["trimal", "-in", cleaned_alignment_path, "-out", trimmed_alignment_path, "-nogaps"], check=True)
	except Exception as e:
		print(str(e))
		print("Failed triming alignment with sequences greater than {0:.1f}% gaps removed.".format(limit*100))
		continue
	try:
		print("Checking trimmed alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
		subprocess.run(["check_trim", trimmed_alignment_path, outfile, trimming_report_path, str(len(raw_records))], check=True)
	except Exception as e:
		print(str(e))
		print("Failed checking trimmed alignment with sequences greater than {0:.1f}% gaps removed.".format(limit*100))
		continue

data_d = {}
for limit in limits:
	outdir = os.path.join(base_path, 'analysis_results', 'gt_%.1f_percent_gaps_removed' % (limit*100))
	trimming_report_path = os.path.join(outdir, "trimming_report_{0:.3f}.txt".format(limit))
	if os.path.isfile(trimming_report_path):
		with open(trimming_report_path) as trimming_report:
			trim_data = trimming_report.readlines()
		data_d[limit] = [trim_data[0].strip()[36:], trim_data[1].strip()[49:], trim_data[2].strip()[32:], trim_data[3].strip()[30:], trim_data[4].strip()[36:]]

trimming_summary_path = os.path.join(base_path, 'analysis_results', "trimming_summary.txt")
with open(trimming_summary_path, 'w') as trimming_summary:
	trimming_summary.write("Gap threshold\tNumber sequences in raw alignment\tNumber sequences removed\tLength of untrimmed alignment\tLength of trimmed alignment\tPercent bases removed by trimming\n")
	for limit in sorted(list(data_d)):
		trimming_summary.write("{0:.2f}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(limit, data_d[limit][0],data_d[limit][1],data_d[limit][2],data_d[limit][3],data_d[limit][4]))


for limit in limits:
	outdir = os.path.join(base_path, 'analysis_results', 'gt_%.1f_percent_gaps_removed' % (limit*100))
	trimmed_alignment_path = os.path.join(outdir, "trimmed_alignment_{0:.3f}.fa".format(limit))
	phylosift_tree_path = os.path.join(outdir, "phylosift_tree_{0:.3f}.tre".format(limit))
	try:
		print("Building tree from alignment with sequences greater than {0:.1f}% gaps removed...".format(limit*100))
		with open(trimmed_alignment_path, 'rb') as trimmed_alignment, open(phylosift_tree_path,'wb') as phylosift_tree:
			subprocess.run(["FastTree", "-nt", "-gtr"], check=True, stdin=trimmed_alignment, stdout=phylosift_tree)
	except Exception as e:
		print(str(e))
		print("Failed building tree from  alignment with sequences greater than {0:.1f}% gaps removed.".format(limit*100))
		continue



outdir = os.path.join(base_path, 'analysis_results', 'raw')
if os.path.isdir(outdir):
	shutil.rmtree(outdir)
os.mkdir(outdir)
raw_outfile = os.path.join(outdir,'raw_alignment.fa')
cleaned_alignment_path = os.path.join(outdir, "cleaned_alignment_raw.fa")
trimmed_alignment_path = os.path.join(outdir, "trimmed_alignment_raw.fa")
trimming_report_path = os.path.join(outdir, "trimming_report_raw.txt")
phylosift_tree_path = os.path.join(outdir, "phylosift_tree_raw.tre")

count = SeqIO.write(raw_records,raw_outfile,'fasta')
try:
	print("Triming raw alignment...")
	subprocess.run(["trimal", "-in", cleaned_alignment_path, "-out", trimmed_alignment_path, "-nogaps"], check=True)
except Exception as e:
	print(str(e))
	print("Failed triming raw alignment.")
	sys.exit(1)

try:
	print("Checking raw trimmed alignment...")
	subprocess.run(["check_trim", trimmed_alignment_path, raw_outfile, trimming_report_path, str(len(raw_records))], check=True)
except Exception as e:
	print(str(e))
	print("Failed checking trimmed raw alignment.")
	sys.exit(1)

try:
	print("Building tree from raw alignment...")
	with open(trimmed_alignment_path, 'rb') as trimmed_alignment, open(phylosift_tree_path, 'wb') as phylosift_tree:
		subprocess.run(["FastTree", "-nt", "-gtr"], check=True, stdin=trimmed_alignment, stdout=phylosift_tree)
except Exception as e:
	print(str(e))
	print("Failed building tree from raw alignment.")
	sys.exit(1)
