function sta = remove_spike_artifact_randomwalk(sta, params)


% ps_3 = fft(p1); f1 = 1/x(end); f = f1*(0:(size(ps_3,1)-1)/2);
% ps_3 = ps_3(2:end,:);
d = diff(sta,[],2);
d = d(:);
n = sum(params.spike_artifact);
r = zeros(n, size(sta,2));
w = ceil(length(d)*rand(size(r,1), size(r,2)));
w = reshape(w,size(r,1), size(r,2));
r = d(w);
r2 = r;
index = find(params.spike_artifact);
index = [index(1) index(end)];
forward = zeros(n, size(sta,2));
forward(1,:) = sta(index(1),:);

r = zeros(n, size(sta,2));
w = ceil(length(d)*rand(size(r,1), size(r,2)));
w = reshape(w,size(r,1), size(r,2));
r = d(w);
r2 = r;

forward = cumsum(forward+r2,1);

reverse = zeros(n, size(sta,2));
reverse(1,:) = sta(index(end),:);

r = zeros(n, size(sta,2));
w = ceil(length(d)*rand(size(r,1), size(r,2)));
w = reshape(w,size(r,1), size(r,2));
r = d(w);
r2 = r;

reverse = cumsum(reverse+r2,1);

replace = (forward+reverse)/2;
% figure(1),plot(mean(sta,2))
% hold on
sta(params.spike_artifact,:) = replace;
% figure(1),plot(mean(sta,2))
% hold off

