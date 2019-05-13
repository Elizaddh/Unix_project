#Project_details
Proteome contains all the proteins in any species.
PLAZA gymnosperm database was used to collect all the proteomes. 
Each protein contain id and sequence.
Id starting with > followed by short species identifier and the numeric value of proetin at the tail.
The sequence is a bunch of characters. No numbers are allowed. Proteins sequence and id in blast database dont have spaces in between them.
Blastp is a command line based program that scans the proteome of specified database and returns the proteins that are most closely related to our query protein. 
Query protein is can be user-specified according to the domain of interest but must be in format, id and sequence.
Domain is the part of the sequence that gives protein its function.
Not all these proteins obtained form the blastp result have domain of interest.
To check if all sequences returned by blastp have the domain in real and to find out the position of domain within the sequence, each blastp result is send to server, which returns biologically significant results. In this case we keep only those protein that have 2 features in the sequence and has a ZnF_GATA domain.
Information that might be needed for processing is selectively extracted from the result from server.
The information about user sequence id is used to extract protein with domain from among the blast hits/homologous.
The information about the start and stop position of the domain is used to identify the domain region and extract it.
Each domain is then given its unique identifier which is the protein sequence id of protein it belongs to.

#Some points on the script and design 
The script uses some techniques that might not seem meaningful at particular step, like introduction of space at the beginning of line, but these are used to help in efficient downstream scripting. 
The major flaw of the design is the sequence and id are dissociated at some point and reunited at the end. There might be a better scripting approach than that.
find is used generously in the first few lines like during unzipping the files and changing the names of the files which might not always produce desired output.
This script uses blastp commands which should be accessible to everyone in computer science department through hopper.
The sequence.fasta file used as query should be in the path. 

##### HAPPY SCRIPTING #### 

