{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf600
{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;\red9\green9\blue9;\red254\green254\blue254;\red39\green40\blue43;
\red0\green0\blue0;\red0\green0\blue0;\red255\green255\blue255;\red38\green38\blue38;\red11\green12\blue12;
\red255\green255\blue255;}
{\*\expandedcolortbl;;\cssrgb\c3137\c3137\c3137;\cssrgb\c99608\c99608\c99608;\cssrgb\c20392\c20784\c22353;
\cssrgb\c0\c0\c0;\csgray\c0;\csgray\c100000;\cssrgb\c20000\c20000\c20000;\cssrgb\c4706\c5098\c5490;
\cssrgb\c100000\c100000\c100000;}
\paperw11900\paperh16840\margl1440\margr1440\vieww20740\viewh12920\viewkind0
\deftab720
\pard\pardeftab720\sl350\partightenfactor0

\f0\fs28 \cf2 \expnd0\expndtw0\kerning0
### Downloading NCBI Data of 16SrRNA Seq for QIIME2 Analysis ###\
\
#00. Set-up\cb3 \
	#Install Miniconda\
> mkdir -p ~/miniconda3\
> wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh\
> bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3\
> rm ~/miniconda3/miniconda.sh\cf4 \cb1 \
\pard\pardeftab720\sl350\partightenfactor0
\cf5 	#Activate Conda\
> source ~/miniconda3/bin/activate\
\pard\pardeftab720\sl360\partightenfactor0
\cf5 > conda init --all\
	# Install GNU parallel\cf4 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
\cf6 \kerning1\expnd0\expndtw0 \CocoaLigature0 > sudo apt-get install parallel\cf2 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\pard\pardeftab720\sl350\partightenfactor0
\cf2 	#Install Qiime2 16SrRNA distribution\
> \cf5 \cb7 conda env create -n qiime2-amplicon-2024.5 --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py39-linux-conda.yml\cf8 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
\cf6 \cb1 \kerning1\expnd0\expndtw0 \CocoaLigature0 	# To activate this environment, use                                                                                                                                                                                                                                                                                                                                         > conda activate qiime2-amplicon-2024.5                                                                                                                                                                                                                                                                                                                                   \
	# To deactivate an active environment, use                                                                                                                                                                                                                                                                                                                                       \
#     $ conda deactivate \cf2 \cb3 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\pard\pardeftab560\slleading20\partightenfactor0
\cf0 \cb1 \kerning1\expnd0\expndtw0 	#Login to Google Cloud Computing (using your ID)\
> ssh -i id_rsa macbook@#####\
PWD: ****\
\
#01. Go to the NCBI Studies Browser\
\cf6 \CocoaLigature0 	#Downloading the raw fast files\
# For SRR IDs\
> wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR\
> wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR\
\
#Unzip fast files\
> gzip -dk *.fastq.gz\
mkdir zip_fastq\
> mv *fastq.gz ./zip_fastq/\
> mkdir manifest\cf0 \CocoaLigature1 \
\
# LOCAL TO SERVER TRANSFER - Metadata file\
> \cf6 \CocoaLigature0 scp -i ~/.ssh/id_rsa /Users/Downloads/Sample_Iss_metadata.tsv macbook@######:~/Iss\
\
#Run ID file\
>scp -i ~/.ssh/id_rsa /Users/Downloads/Sample_Iss_metadata.tsv macbook@######:~/Iss\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
\
#Create Manifest file (https://docs.qiime2.org/2020.8/tutorials/importing/#fastq-manifest-formats)\
    	#create header\
> echo "# paired-end PHRED 33 fastq manifest file for forward and reverse reads" > manifest1.txt\
> echo -e "sample-id\\tforward-absolute-filepath\\treverse-absolute-filepath" >> manifest1.txt\
#create text file with ID path to forward and path to reverse separated by tabs\
> ls *.fastq | cut -d "_" -f 1 | sort | uniq | parallel -j0 --keep-order 'echo -e "\{/\}\\t"$PWD"/\{/\}_1.fastq\\t"$PWD"/\{/\}_2.fastq"' | tr -d "'" > manifest2.txt\
#create full file\
> cat manifest1.txt manifest2.txt > manifest/manifest.tsv\
#Delete text files\
			rm *.txt\
cd ..\
#06. Begin Qiime data import\
> qiime tools import         --type 'SampleData[PairedEndSequencesWithQuality]'         --input-path fastq/manifest/manifest.tsv         --output-path demux.qza         --input-format PairedEndFastqManifestPhred33V2\
\
>qiime demux summarize --i-data demux.qza --o-visualization demux.qzv\
### View Output\
\
#07. Create ASVs\
> nohup qiime dada2 denoise-paired         --i-demultiplexed-seqs demux.qza         --p-trim-left-f 5         --p-trim-left-r 5         --p-trunc-len-f 200         --p-trunc-len-r 200         --p-n-threads 20         --o-table table.qza         --o-representative-sequences rep-seqs.qza         --o-denoising-stats denoising-stats.qza > denoise.log  2>&1 &\
\
# DEBLUR FILTER\
> nohup qiime quality-filter q-score \\\
 --i-demux demux.qza \\\
 --o-filtered-sequences demux-filtered.qza \\\
 --o-filter-stats demux-filter-stats.qza > demux_filter.log 2>&1 &\
\
> nohup qiime deblur denoise-16S \\\
  --i-demultiplexed-seqs demux-filtered.qza \\\
  --p-trim-length 120 \\\
  --o-representative-sequences rep-seqs-deblur.qza \\\
  --o-table table-deblur.qza \\\
  --p-sample-stats \\\
  --o-stats deblur-stats.qza > deblur_denoise.log 2>&1 &\
\
>  qiime metadata tabulate \\\
  --m-input-file demux-filter-stats.qza \\\
  --o-visualization demux-filter-stats.qzv\
\
> qiime deblur visualize-stats \\\
  --i-deblur-stats deblur-stats.qza \\\
  --o-visualization deblur-stats.qzv\
\
> mv rep-seqs-deblur.qza rep-seqs.qza\
\
> mv table-deblur.qza table.qza\
\
> qiime feature-table summarize \\\
  --i-table table.qza \\\
  --o-visualization table.qzv \\\
  --m-sample-metadata-file Sample_Iss_metadata.tsv\
\pard\pardeftab720\sl280\partightenfactor0
\cf9 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
> \cf6 \kerning1\expnd0\expndtw0 \CocoaLigature0 qiime feature-table tabulate-seqs \\\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
  --i-data rep-seqs.qza \\\
  --o-visualization rep-seqs.qzv\
\
#\cf8 \cb10 \expnd0\expndtw0\kerning0
\CocoaLigature1 Generate a tree for phylogenetic diversity analyses\
\
\cf6 \cb1 \kerning1\expnd0\expndtw0 \CocoaLigature0 > qiime phylogeny align-to-tree-mafft-fasttree \\\
  --i-sequences rep-seqs.qza \\\
  --o-alignment aligned-rep-seqs.qza \\\
  --o-masked-alignment masked-aligned-rep-seqs.qza \\\
  --o-tree unrooted-tree.qza \\\
  --o-rooted-tree rooted-tree.qza\cf8 \cb10 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
\cf9 \cb1 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
\cf6 \kerning1\expnd0\expndtw0 \CocoaLigature0 > qiime diversity core-metrics-phylogenetic \\\
  --i-phylogeny rooted-tree.qza \\\
  --i-table table.qza \\\
  --p-sampling-depth 1103 \\\
  --m-metadata-file Sample_Iss_metadata.tsv \\\
  --output-dir core-metrics-results\
\
#Alpha Diversity\
> qiime diversity alpha-group-significance   --i-alpha-diversity core-metrics-results/faith_pd_vector.qza   --m-metadata-file Sample_Iss_metadata.tsv   --o-visualization core-metrics-results/faith-pd-group-significance.qzv\cf9 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\cf6 \kerning1\expnd0\expndtw0 \CocoaLigature0 \
\pard\pardeftab560\slleading20\partightenfactor0
\cf2 \cb3 \expnd0\expndtw0\kerning0
\CocoaLigature1 > \cf6 \cb1 \kerning1\expnd0\expndtw0 \CocoaLigature0 qiime diversity alpha-group-significance \\\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720\pardirnatural\partightenfactor0
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \\\
  --m-metadata-file Sample_Iss_metadata.tsv \\\
  --o-visualization core-metrics-results/evenness-group-significance.qzv\
\
#Beta Diversity\
> qiime diversity beta-group-significance   --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza   --m-metadata-file Sample_Iss_metadata.tsv   --m-metadata-column sex   --o-visualization core-metrics-results/unweighted-unifrac-sex-significance.qzv   --p-pairwise\
\
> qiime diversity beta-group-significance   --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza   --m-metadata-file Sample_Iss_metadata.tsv   --m-metadata-column Subject   --o-visualization core-metrics-results/unweighted-unifrac-subject-group-significance.qzv   --p-pairwise\
\
> qiime emperor plot   --i-pcoa core-metrics-results/unweighted_unifrac_pcoa_results.qza   --m-metadata-file Sample_Iss_metadata.tsv  --o-visualization core-metrics-results/unweighted-unifrac-emperor.qzv\cf2 \cb3 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\cf6 \cb1 \kerning1\expnd0\expndtw0 \CocoaLigature0   \
> qiime emperor plot \\\
  --i-pcoa core-metrics-results/bray_curtis_pcoa_results.qza \\\
  --m-metadata-file Sample_Iss_metadata.tsv \\\
  --o-visualization core-metrics-results/bray-curtis-emperor.qzv\
\
#\cf8 \cb10 \expnd0\expndtw0\kerning0
\CocoaLigature1 Alpha rarefaction plotting\
> \cf6 \cb1 \kerning1\expnd0\expndtw0 \CocoaLigature0 qiime diversity alpha-rarefaction \\\
  --i-table table.qza \\\
  --i-phylogeny rooted-tree.qza \\\
  --p-max-depth 4000 \\\
  --m-metadata-file Sample_Iss_metadata.tsv \\\
  --o-visualization alpha-rarefaction.qzv\
\
# Determine the Sampling depth\
#Examine alpha rarefaction.qzv and table.qzv\
S_DEPTH=1022\
\
#Run again\
> qiime diversity core-metrics-phylogenetic   --i-phylogeny rooted-tree.qza   --i-table table.qza   --p-sampling-depth $S_DEPTH   --m-metadata-file Sample_Iss_metadata.tsv   --output-dir core-metrics-results_1022\
\
#Taxonomy analysis\
> qiime feature-classifier classify-sklearn \\\
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \\\
  --i-reads rep-seqs.qza \\\
--p-confidence 0.8 \\\
  --o-classification taxonomy.qza\
\
> qiime metadata tabulate \\\
  --m-input-file taxonomy.qza \\\
  --o-visualization taxonomy.qzv\
\
> qiime taxa barplot \\\
  --i-table table.qza \\\
  --i-taxonomy taxonomy.qza \\\
  --m-metadata-file sample-metadata.tsv \\\
  --o-visualization taxa-bar-plots.qzv\
\
#Relative Abundance:\
> qiime taxa collapse \\\
  --i-table table.qza \\\
  --i-taxonomy taxonomy.qza \\\
  --p-level 2 \\\
  --o-collapsed-table phyla-table.qza\
\
>  qiime feature-table relative-frequency --i-table phyla-table.qza --o-relative-frequency-table rel-phyla-table.qza\
\
>  qiime tools export --input-path rel-phyla-table.qza --output-path rel-table\
\
# first move into the new directory\
cd rel-table\
# note that the table has been automatically labelled feature-table.biom\
# You might want to change this filename for calrity\
biom convert -i feature-table.biom -o rel-phyla-table.tsv --to-tsv\
}