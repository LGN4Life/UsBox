function OptoState = KeyIDConvert_Opto(KeyID)



OptoState(:,1) = KeyID.OptoState.timestamps;
NoOptoTrials = strfind(KeyID.OptoState.value,'N');
OptoTrials = strfind(KeyID.OptoState.value,'O');
OptoState(OptoTrials,2)=1;
OptoState(NoOptoTrials,2)=0;



