#Script to download/collect domain sequence of all the homologous sequences for any species maintained in Plaza gymnosperm

#download html page with the links to files to download
wget https://bioinformatics.psb.ugent.be/plaza/versions/gymno-plaza/download/index

#extract the link to proteome file for all species to make local database
cat download | tr -d "\r\n" | egrep -o '<a[^>]+>' | egrep -o 'href="ftp:[^"]*' |sed 's/^href="/wget /' | egrep "proteome" > url_list.sh

# download all proteomes in the website
bash url_list.sh

#unzip all the proteome files# gunzip *.gz  would have worked
find . -name "*.gz" | xargs gunzip

#convert .csv file to .fa files #there is a more efficient way to convert file extension in course book/pdf
find . -name '*csv' |sed 's/\.\///'|  sed 's/^\(proteome\..*\)/\1 \1/' | sed 's/^/mv /' | sed 's/csv$/fa/' > format_converter.sh

#make those protein database BLAST standard database 
find -name '*fa' | sed 's/\.\///' | sed 's/^/makeblastdb -in /' | sed 's/$/ -input_type fasta -dbtype prot/'> makingblastdb.sh

#doing blast search for the species of interest
find . -name "*.fa" |  egrep -o  -f  my_species | sed 's/^/blastp -query sequence.fasta -threshold 1e-5 -db proteome./' | sed 's/$/.fa/ ' > blast_script.sh

#perform the blast search
bash blast_script.sh > blastp_out

#collect sequence id of intrest, id is in blastp result
cat blastp_out | egrep '^>'  | sed 's/^> />/' | sort > sequence_ids

#collect sequence of interest from the database
find . -name "*.fa" | xargs cat | egrep -A  1 -f  "sequence_ids" | sed "s/--//" | egrep -o "^.*$" > homologous.txt

#send this sequence of interest to SMART server and retrieve sequences with domain of interest
curl -F "SEQFILE=@homologous.txt" -F "TEXTONLY=1" http://smart.embl-heidelberg.de/smart/batch.pl -o output

##extract domain start and end position for each sequence which has ZnF_GATA domain and two features and clean extra information
cat output | sed "s/^/ /" | tr -d "\n" | egrep -o "USER[^ ]* = [^ ]* [^ ]* = [^ ]* [^=]*=2  DOMAIN=ZnF_GATA START=[0-9]* END=[0-9]*" | sed "s/SMART_PROTEIN_ID = [^ ]* [^ ]* //"  | sed "s/^[^ ]* = /ID=/" | sort  > domain_info

#domain position info and seq id in two files
 cat domain_info | cut -d " " -f 4,5 | sed "s/^[^=]*=\(.*\) [^=]*=\(.*\)/\1-\2/" > domain_position_info
 cat domain_info | cut -d " " -f 1 | sed 's/ID=//' > protein_with_domain

#only homologous protein that has the domain
cat homologous.txt |   egrep -A 1 -f protein_with_domain | egrep -o "^[^-].*$" > homologous_with_domain.txt
cat homologous_with_domain.txt | egrep ">" > to_sort_1
cat homologous_with_domain.txt | egrep "^[^>]" > to_sort_2
paste to_sort_1 to_sort_2 | sort | sed -e 'y/\t/\n/' > sorted_homologous_with_domain.txt

##extracting only domain
cat sorted_homologous_with_domain.txt |sed "s/^>.*$//" | egrep -o "^.*$" | sed "s/^/echo /" | sed "s/$/ | cut -c/" > domain_1_half_script

paste domain_1_half_script domain_position_info > complete_script.sh

## running the complete_script
bash complete_script.sh > domain_only_seq

##giving each domain identity of sequence they belong to 
paste protein_with_domain domain_only_seq -d "\n" | sed "s/^\([A-Z].*[0-9]\)$/>\1/" > domain.fasta

##domain.fasta is ready for multiple sequence alignment###
### ELIZA DHUNGEL #### 5/7/2018 ###
