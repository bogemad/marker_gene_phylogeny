#!/usr/bin/env python

import sys, os, ftplib, gzip, shutil
from Bio import Entrez

def ftp_download(down_path, out_dir):
	server = down_path.split('/')[2]
	chop = len('ftp://') + len(server)
	dirpath = os.path.dirname(down_path)[chop:]
	filename = os.path.basename(down_path)

	ftp = ftplib.FTP(server) 
	ftp.login("anonymous", "daniel.bogema@dpi.nsw.gov.au") 
	ftp.cwd(dirpath)
	ftp.retrbinary("RETR " + filename ,open(os.path.join(out_dir,filename), 'wb').write)
	ftp.quit()
	return os.path.join(out_dir,filename)


def search_genomes(assembly_list, taxon, genome_category):
	handle = Entrez.esearch(db="taxonomy", term=search_term, RetMax = '100000')
	record = Entrez.read(handle)
	taxid_list = record['IdList']
	download_list = []
	for line in assembly_list:
		if line.startswith('#'):
			continue
		data = line.strip().split('\t')
		accession = data[0]
		refseq_category = data[4]
		species_taxid = data[6]
		organism_name = data[7]
		infraspecific_name = data[8]
		if infraspecific_name.startswith('strain='):
			strain_name = infraspecific_name.split('=')[1]
		ftp_path = data[19]
		if genome_category == 'reference':
			if refseq_category == 'representative genome' or refseq_category == 'reference genome':
				if species_taxid in taxid_list:
					filename = "%s_genomic.fna.gz" % os.path.basename(ftp_path)
					download_path = os.path.join(ftp_path, filename)
					corrected_organism_name = organism_name.replace(' ','_').replace('/','').replace(':','-').replace('"','').replace('>','').replace('<','').replace('|','-').replace('?','').replace('*','')
					corrected_strain_name = strain_name.replace(' ','_').replace('/','').replace(':','-').replace('"','').replace('>','').replace('<','').replace('|','-').replace('?','').replace('*','')
					if strain_name in organism_name or strain_name = '':
						outfilename = "%s_%s.fasta" % (corrected_organism_name,accession)
					else:
						outfilename = "%s_%s_%s.fasta" % (corrected_organism_name,corrected_strain_name,accession)
					download_list.append((outfilename, download_path))
		elif genome_category == 'all':
			if species_taxid in taxid_list:
				filename = "%s_genomic.fna.gz" % os.path.basename(ftp_path)
				download_path = os.path.join(ftp_path, filename)
				corrected_organism_name = organism_name.replace(' ','_').replace('/','').replace(':','-').replace('"','').replace('>','').replace('<','').replace('|','-').replace('?','').replace('*','')
				corrected_strain_name = strain_name.replace(' ','_').replace('/','').replace(':','-').replace('"','').replace('>','').replace('<','').replace('|','-').replace('?','').replace('*','')
				if strain_name in organism_name or strain_name = '':
					outfilename = "%s_%s.fasta" % (corrected_organism_name,accession)
				else:
					outfilename = "%s_%s_%s.fasta" % (corrected_organism_name,corrected_strain_name,accession)
				download_list.append((outfilename, download_path))
	if len(download_list) == 0:
		print("0 genomes found! Please check your taxa name.")
		sys.exit(1)
	print("Downloading %d %s genomes..." % (len(download_list),taxon))
	return download_list


def download_genomes(item, base_path, temp_dir):
	outfilename, download_path = item
	if os.path.exists(os.path.join(base_path,'raw_data',outfilename)):
		print("%s has already been downloaded, skipping...")
	else:
		print("Downloading %s..." % outfilename)
		temp_file_path = ftp_download(download_path, temp_dir)
		with gzip.open(temp_file_path, 'rb') as infile:
			with open(os.path.join(base_path,'raw_data',outfilename),'wb') as outfile:
				shutil.copyfileobj(infile, outfile)
		os.remove(temp_file_path)


if __name__ == '__main__':
	Entrez.email = "daniel.bogema@dpi.nsw.gov.au"
	search_term = "%s[subtree] AND species[rank]" % sys.argv[1]
	base_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
	temp_dir = os.path.join(base_path,'.temp')
	if os.path.exists(temp_dir) == False:
		os.mkdir(temp_dir)
	while True:
		genome_category = input("Would you like to download all %s genomes or only reference and representative genomes? [Type 'all' or 'reference']: " % sys.argv[1])
		if genome_category == 'all' or genome_category == 'reference':
			break
		print ("%s not a valid response!" % genome_category)
	assembly_list = open(ftp_download('ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt', temp_dir))
	for item in search_genomes(assembly_list, sys.argv[1], genome_category):
		download_genomes(item, base_path, temp_dir)
		
