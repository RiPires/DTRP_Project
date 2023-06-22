# RADIANCE: Radiotherapy Survival Rate Modeling Interface
This is the repository for the development of the RADIANCE project,
a GUI (Graphical User Interface) to perform survival rate (SR) modeling
by fitting different survival models to clinical data.

This project is being developed in the context of the DTRP
(Diagnosis and Therapy with Radiation and Protons)
class of 2022/2023.

# Authors: 
              R. Matoza Pires - fc49807@alunos.fc.ul.pt
              A. Pardal
              R. Santos

# Supervisor:
              Prof. Dr. Brígida C. Ferreira

# Last Update: 22/06/2023 
  Program under development using the latest versions of MATLAB: R2023a and R2022b
# --------------------------------------------------------------------------------------

The folder "code" contains the files related with the fitting functions of the program
"fit1.m", "fit2.m" and "BED.m", under development;

The folder "Interface" contains the files dedicated to the development of the grafical interface of the program:

  "FitModel" contains the latest/stable version of the program, that include the previously mentioned files;
  # !!!   To launch the interface run the "main.m" script in MATLAB   !!! #

  "dev" is a development folder, containing an old/not-stable version of the program;
  
  "terProMATLAB" and "teraProOctave" are the original versions of an example project,
  built in MATLAB and Octave, respectively;

The folder Tests contains scripts for testing functionalities:
  AddMatrix.m (works in both MATLAB and Octave)
