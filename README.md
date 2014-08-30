# fg_acq  
This program attempts to computationally model the acquisition of filler-gap constructions as observed by Seidl et al (2003) and by Gagliardi et al (2014). This software was initially presented in van Schijndel and Elsner (2014).

This code was deesigned for research rather than general use, so there are some things that should be generalized at some point...

## Requirements  
  CHILDES (and BabySRL annotations)  
  megam
  
#### Python packages:  
    ast  
    nltk   
    numpy  
    scipy

## Edits
  Before running the code, you'll need to update scripts/buildChunker.py and scripts/chunkCHILDES.py  
    Replace '/home/compling/megam' with your location for megam
    
  scripts/acquireFG.py has a bunch of flags with descriptive comments at the beginning that need to be set in order to ensure the model learns what you want it to learn.

## References

Annie Gagliardi, Tara M. Mease, and Jeffrey Lidz. 2014. "Discontinuous development in the acquisition of filler-gap dependencies: Evidence from 15- and 20-month-olds." Harvard unpublished manuscript:
http://www.people.fas.harvard.edu/~gagliardi.

Amanda Seidl, George Hollich, and Peter W. Jusczyk. 2003. "Early understanding of subject and object wh-questions." Infancy, 4(3):423{436.

Marten van Schijndel and Micha Elsner. 2014. "Bootstrapping into filler-gap: An acquisition story." In Proceedings of the 52nd Annual Meeting of the Association for Computational Linguistics (ACL 2014).
