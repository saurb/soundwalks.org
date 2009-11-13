# soundwalks.org
Soundwalks.org is a site that allows people to share environmental sound recordings with each other. These recorded experiences are known as "[soundwalks](http://www.acousticecology.org/)." Besides uploading sounds, users participate in social meaning construction through tagging, annotation, and discussion of environments. The core of the site centers around an interactive map application whereby people can experience virtual soundscapes--similar to Google Street View, but for sounds. 

In addition to exploration and discussion, soundwalks.org aims to focus on composition of both real and virtual soundwalks as a means of understanding one's environment and artistic expression.

# Technology
soundwalks.org uses the [sirens-ruby](http://www.github.com/plant/sirens-ruby) library for the segmentation, indexing, and retrieval of environmental sounds. 
 
# Acknowledgements
soundwalks.org is a research project within the [Arts, Media, and Engineering](http://ame.asu.edu/) program at [Arizona State University](http://asu.edu/). For more information, the following papers may be of interest:

1. Gordon Wichern, H. Thornburg, B. Mechtley, A. Fink, A Spanias, and K. Tu, “Robust multi-feature segmentation and indexing for natural sound environments,” in _Proc. of IEEE/EURASIP International Workshop on Content Based Multimedia Indexing (CBMI)_, Bordeaux France, July 2007. [(PDF)](http://www.public.asu.edu/~gwichern/CBMI07.pdf)
2. Gordon Wichern, J. Xue, H. Thornburg, and A. Spanias, “Distortion-aware query-by-example of environmental sounds,” in _Proc. of IEEE Workshop on Applications of Signal Processing to Audio and Acoustics (WASPAA)_, New Paltz, NY, October 2007. [(PDF)](http://www.public.asu.edu/~gwichern/WASPAA07.pdf)
3. J. Xue, Gordon Wichern, H. Thornburg, and A. Spanias, “Fast query-by-example of environmental sounds via robust and efficient cluster-based indexing,” in _Proc. of IEEE International Conference on Acoustics Speech and Signal Processing (ICASSP)_, Las Vegas, NV, April 2008. [(PDF)](http://www.public.asu.edu/~gwichern/cluster_ICASSP08.pdf)

Additionally, work on Sirens is supported by the [National Science Foundation](http://www.nsf.gov/) under Grants NSF IGERT DGE-05-04647 and NSF CISE Research Infrastructure 04-03428.

# Copyright
All soundwalks.org code, unless otherwise specified, is copyright 2009 Arizona State University, licensed under the [GNU GPL](http://creativecommons.org/licenses/GPL/2.0/). See COPYING for details. [Sirens](http://www.github.com/plant/sirens) and [sirens-ruby](http://www.github.com/plant/sirens-ruby) are licensed under the [GNU LGPL](http://creativecommons.org/licenses/LGPL/2.1/). See individual projects for more details.

Additionally, soundwalks.org makes use of several open source Rails plugins (with various modifications), most (if not all) available on [Github](http://www.github.com). See vendor/plugins for a full list of plugins and their licensing details.
