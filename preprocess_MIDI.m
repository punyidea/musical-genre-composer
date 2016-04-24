function [ note_mat, tempo] = preprocess_MIDI( midi_file)
%PREPROCESS_MIDI Summary of this function goes here
%   Detailed explanation goes here
midi = readmidi(midi_file);
Notes = midiInfo(midi,0);
[keys,key_times] =extract_key_sig(midi);
[tempo,tempo_times] = getTempoChanges(midi);
dt= tempo(1);
old_key = keys(1);
[PR,~,note_scale] = piano_roll(Notes,dt);
old_mat(note_scale-20,:) = PR;
right_key = 0;
A = (1:89)';
note_mat = transpose_mat(old_mat,old_key,right_key);
note_mat = double(note_mat~=0);
return

function final_note_mat = transpose_mat(proto_note_mat,mat_key,new_key)
%once made, transpose the proto_matrix to the "right" key, C major/A minor
% Return the final matrix.

%at this point find the amount we have to subtract
transp_amount =  new_key- mat_key;

transp_amount = mod(transp_amount + 6,12)-6;
if transp_amount <-size(proto_note_mat,1)
    disp('Transposition not possible. Matrix too small')
    return
end
    
final_note_mat = zeros(88,size(proto_note_mat,2));

final_note_mat(max(1,1+transp_amount):min(88,size(proto_note_mat,1)+transp_amount),:)...
    = proto_note_mat(max(1-transp_amount,1):min(size(proto_note_mat,1),88-transp_amount),:);


return

function piano_roll_to_mat(piano_roll,tempo,start_time)
%once inputting a piano roll, convert the roll into an adequate time matrix

return
function [keys,keys_time] = extract_key_sig(midi)
keys = [];
keys_time = [];
for i=1:length(midi.track)
  cumtime=0;
  for j=1:length(midi.track(i).messages)
    cumtime = cumtime+midi.track(i).messages(j).deltatime;
%    if (strcmp(midi.track(i).messages(j).name,'Set Tempo'))
    if (midi.track(i).messages(j).midimeta==0 && midi.track(i).messages(j).type==89)
      keys_time(end+1) = cumtime;
      data = midi.track(i).messages(j).data;
      if (data(1)<=7)
       %   0   1   2    3    4   5     6     7   
      %ss={'C','G','D', 'A', 'E','B',  'F#', 'C#'};
      ss = [0,  7,  2,   9,   4,  11,    6,    1];
      key = ss(data(1)+1);
      elseif (data(1)>=249)
       %    1   2    3    4   5     6    7   
       %   255   ...                    249
       %ss={'F','Bb','Eb','Ab','Db','Gb','Cb'};
       ss = [5, 10,   3,   8,   1,   6,   11];
       key = ss(255-data(1)+1);
       
       if data(2)~=0% meaning that it's minor
           
        key = key  +3;
       end
      
      else
          key = 0;
      end
      keys(end+1) =  mod(key,12);
    end
  end
end

return