function  pupil_data = remove_blinks(pupil_data,size_threshold)
if nargin==1
    size_threshold = 4000;
end
d = diff(pupil_data.size);


d = find(abs(d)>300);
d = d(d>5);
for blink_index = 1:length(d)
    if d(blink_index)-5>0 & d(blink_index)+5<size(pupil_data.size,1)
        pupil_data.size(d(blink_index)-5:d(blink_index)+5) = nan;
    end
end

blink = find(pupil_data.status ==0);
blink = blink(blink>5);
pupil_data.size(1:5) = nan;
for blink_index = 1:length(blink)
    if blink(blink_index)-5>0 & blink(blink_index)+5<size(pupil_data.size,1)
        pupil_data.size(blink(blink_index)-5:blink(blink_index)+5) = nan;
    end
    
end

blink = find(pupil_data.size < size_threshold);
blink = blink(blink>5);
pupil_data.size(1:5) = nan;
for blink_index = 1:length(blink)
    if blink(blink_index)-5>0 & blink(blink_index)+5<size(pupil_data.size,1)
        pupil_data.size(blink(blink_index)-5:blink(blink_index)+5) = nan;
    end
    
end

end