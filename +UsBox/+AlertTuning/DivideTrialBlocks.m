function BlockTrial = DivideTrialBlocks(TrialType,TrialThreshold)
% excludes trials in a block at position less than the TrialThreshold, for
% example trials 1 and 2  are excluded if TrialThreshold =3
BlockTrial = cell(2,1);
BlockChange =cat(1,logical(1),TrialType(2:end,2)~=TrialType(1:end-1,2)); %indicates the trials that mark block transitions
BlockTrial{1}=zeros(length(TrialType),1);
BlockTrial{2}=logical(zeros(length(TrialType),1));
BlockNumber = 1:sum(BlockChange);
BlockTrial{1}(BlockChange)=BlockNumber;
BlockTrial{2}(BlockChange)=1;
BlockChangeID = find(BlockChange);
for block_index =1:length(BlockChangeID)-1
    BlockTrial{1}(BlockChangeID(block_index):BlockChangeID(block_index+1)-1)=BlockTrial{1}(BlockChangeID(block_index));
    BlockLength = 1:length(BlockChangeID(block_index):BlockChangeID(block_index+1)-1);
    BlockLength =BlockLength>TrialThreshold;
    

    BlockTrial{2}(BlockChangeID(block_index):BlockChangeID(block_index+1)-1)=BlockLength;
    
    
end
BlockTrial{1}(BlockChangeID(end):end)=BlockTrial{1}(BlockChangeID(end));
BlockLength = 1:length(BlockChangeID(end):length(BlockTrial{2}));
BlockLength =BlockLength>TrialThreshold;
BlockTrial{2}(BlockChangeID(end):end)=BlockLength;

