% %%% Read in Midi files
% maxLen = 80;
% [Xtrain,noteScale,aveDt]=readMidiFromFolder('Nottingham/train/',16,maxLen);
% numNotes = max(noteScale)-min(noteScale)+1;
% 
% % Creating an object to store train and test data
% data=DataClasses.DataStore();
% data.valueType=ValueType.binary;
% data.trainData=Xtrain;
% data.validationData=Xtrain;

% %%%create DBN
% dbn=DBN();
% dbn.dbnType='autoEncoder';
% % RBM1
% rbmParams=RbmParameters(1024,ValueType.binary);
% rbmParams.maxEpoch=2000;
% rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
% rbmParams.performanceMethod='reconstruction';
% rbmParams.rbmType=RbmType.generative;
% rbmParams.moment=[0.9];
% dbn.addRBM(rbmParams);
% % RBM2
% rbmParams=RbmParameters(256,ValueType.binary);
% rbmParams.maxEpoch=1000;
% rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
% rbmParams.performanceMethod='reconstruction';
% rbmParams.rbmType=RbmType.generative;
% dbn.addRBM(rbmParams);
% % RBM3
% rbmParams=RbmParameters(64,ValueType.binary);
% rbmParams.maxEpoch=1000;
% rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
% rbmParams.performanceMethod='reconstruction';
% rbmParams.rbmType=RbmType.generative;
% dbn.addRBM(rbmParams);
% %train dbn
% dbn.train(data)
% %get outputs of last hidden layer
% lastLayerSamples = dbn.getFeature(Xtrain);
% %generate a piano roll
% generatedPR = dbn.generateData(lastLayerSamples(1,:));

%%% write midi out
% original song after reading in and processing
% M=pianoRoll2matrix(reshape(Xtrain(1,:),numNotes,maxLen),aveDt,noteScale);
% midi_new = matrix2midi(M);
% writemidi(midi_new, 'testout.mid');

%%% write out reconstructed song from dbn
M=pianoRoll2matrix(reshape(generatedPR,numNotes,maxLen),aveDt,noteScale);
midi_new = matrix2midi(M);
writemidi(midi_new, 'generatedPR10.mid');