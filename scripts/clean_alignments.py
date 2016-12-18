#!/usr/bin/env python

import sys, os, re
from Bio import SeqIO

base_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

for limit in (0.1, 0.05, 0.025):
	raw_records = []
	records = []
	for item in os.listdir(os.path.join(base_path,'raw_data','PS_temp')):
		record = SeqIO.read(os.path.join(base_path, 'raw_data', 'PS_temp', item, 'alignDir', 'concat.codon.updated.1.fasta'), 'fasta')
		record.id = re.sub(r'\.1\..*','',record.id)
		record.name = ''
		raw_records.append(record)
		if sum(1 for x in record.seq if x == '-')/len(record) < limit:
			records.append(record)
	outfile = os.path.join(base_path, 'analysis_results','cleaned_alignment_%.3f.fa' % limit)
	count = SeqIO.write(records,outfile,'fasta')

raw_outfile = os.path.join(base_path, 'analysis_results','raw_alignment.fa')
count = SeqIO.write(raw_records,raw_outfile,'fasta')