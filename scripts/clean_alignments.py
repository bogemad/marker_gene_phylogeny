#!/usr/bin/env python

import sys, os, re, shutil
from Bio import SeqIO

base_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

for limit in (0.1, 0.05, 0.025):
	raw_records = []
	records = []
	ditched_records = []
	outdir = os.path.join(base_path, 'analysis_results', 'gt_%.1f_percent_gaps_removed' % (limit*100))
	os.mkdir(outdir)
	for item in os.listdir(os.path.join(base_path,'raw_data','PS_temp')):
		record = SeqIO.read(os.path.join(base_path, 'raw_data', 'PS_temp', item, 'alignDir', 'concat.codon.updated.1.fasta'), 'fasta')
		record.id = re.sub(r'\.1\..*','',record.id)
		record.name = ''
		record.description = ''
		raw_records.append(record)
		if sum(1 for x in record.seq if x == '-')/len(record) < limit:
			records.append(record)
		else:
			ditched_records.append(record)
	outfile = os.path.join(outdir,'cleaned_alignment_%.3f.fa' % limit)
	ditched_outfile = os.path.join(outdir,'ditched_sequences_%.3f.fa' % limit)
	count = SeqIO.write(records,outfile,'fasta')
	count = SeqIO.write(ditched_records,ditched_outfile,'fasta')

outdir = os.path.join(base_path, 'analysis_results', 'raw')
os.mkdir(outdir)
raw_outfile = os.path.join(outdir,'raw_alignment.fa')
count = SeqIO.write(raw_records,raw_outfile,'fasta')