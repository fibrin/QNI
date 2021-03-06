GRADIENT VECTOR FLOW DEMONSTRATION USING MATLAB
Chenyang Xu and Jerry Prince
Image Analysis and Communications Laboratory
Johns Hopkins University
June 17, 1997, updated on 9/9/1999

Please see contact and copyright information below.

1. Introduction and Installation Instructions
----------------------------------------------

Welcome to the Gradient Vector Flow (GVF) Active Contour Toolbox.  The
Matlab *.m files in this software distribution implement our GVF snake,
the original (Kass, Witkin, and Terzopoulos) snake, the balloon snake,
and the distance snake. These programs were designed, written and tested
by Chenyang Xu and Jerry Prince. 

To install this software, simply unzip the file into an empty directory,
making sure to ask your unzipper program to restore the directory
structure of the zipped files. In this documentation, we will assume
that you have unzipped the files into C:\GVF.


2. Documentation
----------------

We have included two research papers that describe GVF. You can find
these in C:\GVF\papers.

Brief descriptions of the software modules can be found in this file
below.  For more detail, you should run Matlab, add the path
C:\GVF\snake, and type "help function-name".  For even more help, you can
read the *.m files themselves. 

Also, see our GVF demonstration website: http://iacl.ece.jhu.edu/projects/gvf


3. MATLAB functions
-------------------

The MATLAB functions included in the distribution are found in
C:\GVF\snake (assuming the distribution was unzipped into C:\GVF).
They are classified and listed as follows:

 Image input/output
   rawread       - Read a Portable Bitmap file, or a raw file
   rawwrite      - Write a Portable Bitmap file, or a raw file

 Image Display
   imdisp        - Display an image

 Active Contour
   snakeinit     - Initialize the snake manually
   snakedeform   - Deform snake in the given external force field
   snakedeform2  - Deform snake in the given external force field with
                   pressure force
   snakedisp     - Display a snake

   snakeinterp   - Interpolate the snake adaptively
   snakeinterp1  - Interpolate the snake at a fixed resolution
                   (better implemented than snakeinterp)

 Gradient Vector Flow
   GVF           - Compute the gradient vector flow field

 Other
   dt            - Simple distance transform
   gaussianBlur  - Blurring an image using gaussian kernel   
   gaussianMask  - Generate a discrete gaussian mask

To use these functions, add the path C:\GVF\snake to the Matlab path
using the "path" command. Once the path is set, you can type "help
snake" to list more details about the above functions.


4. Examples

To see how these functions work, it is best to start by running
the following example macros. To do this, in Matlab cd to the directory
C:\GVF\examples.  Then type one of the following commands and follow
the instructions of the demo. 

   balloon_ex.m
   distance_ex.m
   gvf_ex.m
   tradition_ex.m

5. Test Images
--------------

./images/U64.pgm   - a U-shaped object 
./images/room.pgm  - a room-shaped object


6. Contact Information
----------------------

Image Analysis and Communications Lab
Department of Electrical and Computer Engineering
The Johns Hopkins University
Baltimore, MD 21218

E-mail: chenyang@jhu.edu, prince@jhu.edu
Phone: 410-516-7567 (lab)
FAX:   410-516-5566


7. Copyright and Disclaimer
---------------------------

Copyright (c) 1996-1997 Chenyang Xu and Jerry Prince.

This software is copyrighted by Chenyang Xu and Jerry Prince.  The
following terms apply to all files associated with the software unless
explicitly disclaimed in individual files. 

The authors hereby grant permission to use, copy, and distribute this
software and its documentation for any purpose, provided that existing
copyright notices are retained in all copies and that this notice is
included verbatim in any distributions. Additionally, the authors grant
permission to modify this software and its documentation for any
purpose, provided that such modifications are not distributed without
the explicit consent of the authors and that existing copyright notices
are retained in all copies. 

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES
THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE. 

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 

=========================================================================

