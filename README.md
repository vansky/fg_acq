# fg_acq  
This program attempts to computationally model the acquisition of filler-gap constructions as observed by Seidl et al (2003) and by Gagliardi et al (2014). This software was initially presented in van Schijndel and Elsner (2014).

This code was designed for research rather than general use, so there are some things that should be generalized at some point...

## Requirements  
    CHILDES (and BabySRL annotations)  
  
#### Python (2.7) packages:  
    ast
    nltk (with the following sub-package)
        punkt
    numpy  
    scipy

Run the following set of commands to get the nltk sub-package(s) if you don't have them:  

    python  
    nltk.download()  
    d #Download  
    punkt  
  
  If you just want to replicate the results of van Schijndel and Elsner (2014), just run: `make acl2014`  
  
  `scripts/acquireFG.py` has a bunch of commented flags at the beginning that can be tweaked to alter what the model learns.
  
  Similarly, `scripts/testFG.py` and `scripts/evalFG.py` have commented flags to change the type of eval you run

## References

Annie Gagliardi, Tara M. Mease, and Jeffrey Lidz. 2014. "Discontinuous development in the acquisition of filler-gap dependencies: Evidence from 15- and 20-month-olds." Harvard unpublished manuscript:
[http://www.people.fas.harvard.edu/~gagliardi](http://www.people.fas.harvard.edu/~gagliardi).

Amanda Seidl, George Hollich, and Peter W. Jusczyk. 2003. "Early understanding of subject and object wh-questions." Infancy, 4(3):423-436.

Marten van Schijndel and Micha Elsner. 2014. "Bootstrapping into filler-gap: An acquisition story." In Proceedings of the 52nd Annual Meeting of the Association for Computational Linguistics (ACL 2014). [http://www.ling.ohio-state.edu/~vanschm/resources/uploads/vanschijndel_elsner-2014-acl.pdf](http://www.ling.ohio-state.edu/~vanschm/resources/uploads/vanschijndel_elsner-2014-acl.pdf)
