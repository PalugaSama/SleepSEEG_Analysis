% %% ------------- SleepSEEG  ---------------------
% 
% %  RUN . 
% [SleepStage]=SleepSEEG(FileList,ExtraFiles)
% 
% % 'SAVE AS' the output 'ans' in a variable 'Sleep_Confidence' in a file :
% %  Patient X > Output_SleepSEEG > Sleep_Confidence_SX  
% 
% %  --- Create a clone SC_SX
% 
%SC = Sleep_Confidence
% % Save SC with the name SC_SX_NX in the patient appropriate file 
% 
% 
% %% ----------- Analyses Sleep Confidence (SC)------------------- %%
% 
% % Confidence Level (High Confidence for Sleep SEEG = theta > 0.5)
% 
theta = 0.5;
% 
% 
% % Run function Epochs to obtain : 
% 
%     % h = histogram of repartition by Sleep Stages
%     % statsMatrix = Small Matrices of stats with selected epochs
%     % time = graph of repartition by time 
%     % TimeStamps = list of timestamp for epochs
%     % EpochsInfo = Selected Epochs 
% 
[h, statsMatrix, time, Timestamps, EpochsInfo] = Epochs(SC, theta) 
% 
% %%

