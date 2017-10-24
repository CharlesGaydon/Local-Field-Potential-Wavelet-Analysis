# LFP-Oculomotor Time-Frequency Analysis Scripts
Last edited : 09/2016

#### I. What is it ?

This folder contains a set of Matlab scripts whose main purpose is :

- to isolate time windows of interest (called *trials*) from  [Local Field Potential](https://en.wikipedia.org/wiki/Local_field_potential) (or LFP) signals. Those are caracterized by the oculomotor activity of the non-human primate, e.g. saccades, and/or the event of the performed task. 
- to perform on those trials a time-frequency analysis using morlet's wavelet. It is higly modular, and enables nice plotting of the results.

All data import and analysis parameters definition can be done in <kbd>LFP_ocular_trials</kbd>, which will now be called the main script. **It should be the only one you need to modify in order to proceed to the time-frequency analysis.** Also the <kbd>SUB_ocular_analysis</kbd> Matlab file can be edited to perform different studies on the saccade that occur in the temporal windows of interest.

#### II. How to make it work ?
To use this set of scripts, open Matlab, browse your files and add to your path the folder which contains them (default is <kbd>LFP_Oculomotor_TF_analysis</kbd>), alongside with the folder and subfolder containing all the FieldTrip scripts. Then open the <kbd>LFP_ocular_trials</kbd> Matlab file. Modify the "Data import" section to import your own data and then you can run the following cod lines block by block.

#### III. Pipeline of the data treatment
Here are the main steps followed by the main script. For further details about the parameters definition and the mathematical process of the re-sampling, refer yourself to the help of the adequate functions.

##### 1. Data Import
This script uses the event data (cod and timestamp) of the experiment, oculomotor data already cleaned from artefacts and lfp data brought to the same sampling rate as the oculomotor data. Once you cleaned your own data, it is easy to adapt them to the format I chose, in the 'Data import' section of the main script.
Note that this script is designed to study an unique lfp signal : it doesn't handle multiple electrodes at the same time.
##### 2. Trial definition
You can extract the trials from the continuous lfp data according to several criteria. Trials can be event-centered or saccade-centered. 

- Event-centered trials : the trials will be a specific time window around the event of interest, that you can ask to be followed by another particular event. You can also remove the trials that contain or don't contain a saccade in a particular temporal area around them, but that is optionnal.
- Saccade-centered : the trials will be a specific time window around the saccades. You can ask the saccade to be in a particular temporal area near an event of interest, possibly followed by another specific event. You may also want to remove the saccades which have another saccade occuring in a particular temporal neighborhood. It is possible.

Note that the <kbd>SUB_ocular_analysis</kbd> function is called during this trial definition and will plot several figures.
The eye, event and LFP data are then brought to a FieldTrip format and the trials are made by the FieldTrip *ft_definetrial* and *ft_redefinetrial*</kbd> functions.

##### 3. Visualisation and artefact rejection
FieldTrip functions *ft_databrowser* and *ft_rejectvisual* are used to first visualize the trials one by one and then to visually select the trials to remove from the set.

##### 4. Morlet's Wavelett convolution
A time-frequency analysis on the cleaned data is then performed by the FieldTrip *ft_freqanalysis* function. It can be chosen to do it on each trial ('keep the trials') or to do it on the averaged trials ('do not keep the trials').

- Do not keep the trials : the powerspectrum will be displayed by the <kbd>TF_singleplot</kbd> function, with several graphic parameters and a possible baseline normalization, whose choice is up to you.
- Do keep the trials : if this option is chosen, it should with the idea to then compare the spectral condition of one condition from another one (e.g. different following event). To do so :
    - Save the output of the *ft_freqanalysis* (or give it another name and don't erase it);
    - Do steps 1 to 4 with another condition but the same general parameters (time-windows, etc.) and keep the trials too;
    - Compare the two powerspectrum with the function <kbd>TF_multiplot</kbd>, which can perform two types of non-parametrical comparisons using a re-sampling process and will plot the significant differences.  
    Keeping the trials can also allow you to use the <kbd>TF_highlight_burst</kbd> function which show for all the trials simultaneously the time evolution of the power in a specific spectral band, in order to see if the power variations are occuring always at the same time or not.

#### IV. List of Matlab files and requirement
- This folder contains the following Matlab files. 

>LFP_ocular_trials 
  LFP_ocular_trials_fun  
  SUB_cod_centered_trials  
  SUB_ocular_centered_trials 
  SUB_simple_ocular_trials  
  SUB_event_transform
  SUB_ocular_analysis  
  SUB_SUB_applybaseline  
  TF_highlight_burst 
  TF_multiplot
  TF_singleplot 

Those scripts needs FieldTrip to work, which is a toolbox distributed under the terms of the GNU General Public Licence as published by the Free Software Foundation. The version I used was fieldtrip-20160727 but later versions should work too. It can be downloaded on the [FieldTrip website](http://www.fieldtriptoolbox.org/download "Download FieldTrip").

- Additional contents are :

> CJT_TaskSchema_Timings (PDF)  
> CJT_Codes (XLXS)

Those two additional documents give key information about the experiment from which the data I used where obtained. It can help you if you are dealing with the same data.

- and :

> TF_ocular_analysis_main_results.pptx  

Here are a presentation of some of the main figures given by the analysis, with detailed comments about how they were obtained. This was not intended for publication, but can give you insight on the kind of information we can get.


### Author
My name is Charles Gaydon and I wrote those scripts in August 2016, between my third and my fourth year as a student of the INSA de Lyon, during a one month volunteer internship at the Stem-Cell and Brain Research Institute (INSERM U1208) in Lyon, FRANCE. I was inspired by the artefact rejection scripts written by Vincent Fontanier, a searcher in the same team as I, at the time.

