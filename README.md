dartBrainbow
============

dartBrainbow is a simply dart library for brainbow sequences. Who ever has some practical use for this, feel free to play with it.

Example
-------

	#import('lib/bb.dart');
	
	// Initiate a new sequence
	BBSeq seq = new BBSeq('+D +4 +! -! -2 -A +A +3 +! -! -1 -A');
	
	// Normalize the sequence
	BBSeq norm = BBUtils.normalize(seq);

	print("Sequence: " + seq);
	print("Normalized: " + norm);

	// calculate the color propabilities
	Map<BBSeq, num> colors = BBUtils(norm);
	print(colors);
