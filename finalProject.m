addpath DeeBNetV3.1/DeeBNet
addpath matlab-midi-master/src
%%% Read in Midi files
maxLen = 72;
numQN=12;
[Xtrain,noteScale,aveDt]=readMidiFromFolder('Nottingham/train/',numQN,maxLen);
numNotes = max(noteScale)-min(noteScale)+1;

% % Creating an object to store train and test data
data=DataClasses.DataStore();
data.valueType=ValueType.binary;
data.trainData=Xtrain;
data.validationData=Xtrain;

% %%%create DBN
dbn=DBN();
dbn.dbnType='autoEncoder';
% RBM1
rbmParams=RbmParameters(1024,ValueType.binary);
rbmParams.maxEpoch=2000;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
rbmParams.performanceMethod='reconstruction';
rbmParams.rbmType=RbmType.generative;
rbmParams.moment=[0.9];
dbn.addRBM(rbmParams);
% RBM2
rbmParams=RbmParameters(256,ValueType.binary);
rbmParams.maxEpoch=1000;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
rbmParams.performanceMethod='reconstruction';
rbmParams.rbmType=RbmType.generative;
dbn.addRBM(rbmParams);
% RBM3
rbmParams=RbmParameters(64,ValueType.binary);
rbmParams.maxEpoch=1000;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
rbmParams.performanceMethod='reconstruction';
rbmParams.rbmType=RbmType.generative;
dbn.addRBM(rbmParams);
% RBM4
rbmParams=RbmParameters(16,ValueType.binary);
rbmParams.maxEpoch=1000;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
rbmParams.performanceMethod='reconstruction';
rbmParams.rbmType=RbmType.generative;
dbn.addRBM(rbmParams);
%train dbn
dbn.train(data)
%get outputs of last hidden layer
lastLayerSamples = dbn.getFeature(Xtrain);
%generate a piano roll
generatedPR = dbn.generateData(lastLayerSamples(1,:));

save('dbn.mat','dbn','maxLen','numQN','numNotes','aveDt','noteScale')
%%% write midi out
% original song after reading in and processing
% M=pianoRoll2matrix(reshape(Xtrain(1,:),numNotes,maxLen),aveDt,noteScale);
% midi_new = matrix2midi(M);
% writemidi(midi_new, 'testout.mid');

%%% write out reconstructed song from dbn
M=pianoRoll2matrix(reshape(generatedPR,numNotes,maxLen),aveDt,noteScale);
midi_new = matrix2midi(M);
writemidi(midi_new, 'generatedPR1.mid');

%to generate data from last hidden layer
% test =rand(1,16);
% test(test>=0.5)=1;
% test(test<0.5)=0;
% [generatedData]=dbn.generateData(test);

%compose on top of test song
[Xtest,~,aveDt]=readMidiFromFolder('Nottingham/temp/',numQN,maxLen,noteScale);
% original song after reading in and processing
M=pianoRoll2matrix(reshape(Xtest(1,:),numNotes,maxLen),aveDt,noteScale);
midi_new = matrix2midi(M);
writemidi(midi_new, 'test1.mid');

%%% write out reconstructed song from dbn
[reconstructedData]=dbn.reconstructData(Xtest(1,:));
M=pianoRoll2matrix(reshape(reconstructedData,numNotes,maxLen),aveDt,noteScale);
midi_new = matrix2midi(M);
writemidi(midi_new, 'test1Improv.mid');
