# QT-interval Time Detection

By Artur Freitas, arturfreitas09@gmail.com 31/01/2022
A MATLAB script was created to find out the mean time of the QT-interval and the corrected QT-interval in ECGs from the 'ECG Effects of Ranolazine, Dofetilide, Verapamil, and Quinidine' [1] database from PhysioNet (https://physionet.org/content/ecgrdvq/1.0.0/), published by *Johannesen L et al*.
The code removes the high and low frequency noises in addiction to the electrical grid interference. Then, the signal is normalized and from it the R-peaks are found as well as the S-peaks and T-peaks, also the RR-interval is calculated. All this information enables to get the beggining of the QT-interval, from which is extracted the end of such segment. This way, the QT-interval is calculated in addiction to the corrected QT-interval (using the RR method).
This script is molded to work with the database mentioned above. To use this script please import first an ECG, in particular from such database.

[1] - Johannesen L, Vicente J, Mason JW, Sanabria C, Waite-Labott K, Hong M, Guo P, Lin J, Sørensen JS, Galeotti L, Florian J, Ugander M, Stockbridge N, Strauss DG. Differentiating Drug-Induced Multichannel Block on the Electrocardiogram: Randomized Study of Dofetilide, Quinidine, Ranolazine, and Verapamil. Clin Pharmacol Ther. 2014 Jul 23. doi: 10.1038/clpt.2014.155.
