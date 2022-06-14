function s =  subtract_noise(s, t, c)

LineNoise =t*2*pi*60;
LineNoise =repmat(LineNoise,size(s,2),1);
LineNoise=imag(c).*sin(LineNoise)+real(c).*cos(LineNoise);
s= s-(LineNoise');
