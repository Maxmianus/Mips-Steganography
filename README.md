 # Contributers: William Fink, Christopher Dixon, & Tracy Jackson

*** ReadMe For Our Encoding and Decoding Program***

To run our program you need the MARS Simulator 

*** Below Is How The Files Should Be Filled Out ***

fileName is the file that gets encoded/decoded
fileEncode is the file that encodes fileName
fileWriteName is the output file

Encoding:

C:\...\Image1.pgm,
C:\....\Image2.pgm

Where image1 is the image hiding the other image and image2 is the image being hidden in another.

C:\....\Output.pgm

 Is image1 with image2 encoded into it.

If using a Windows environment, the file should look like 

"C:\\Users\\WHF17\\Desktop\\Image1.pgm"

Decoding:

C:\....\Image1.pgm

Is the image being decoded and 

C:\....\Output.pgm

Is the hidden image transformed back its original image.

If using a Windows environment, the file should look like

"C:\\Users\\WHF17\\Desktop\\Image1.pgm"



Text File Format:
The text file requires to be in windows format, meaning a carrier return at the end of every line along with the new line character:    “\r\n”.

***** NOTE: *****
For decoding purposes, the image that is decoded is fileName. If trying to decode the file that was just encoded, take the fileWriteName file and place that in fileName

***** Prompts *****
When prompted enter an ‘e’ for encoding and a ‘d’ for decoding
