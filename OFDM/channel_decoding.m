function  out = channel_decoding(data)
%% 信道解码 
%码率为0.5
rrt=lteRateRecoverTurbo(data,length(data)/2-24,0);
td=lteTurboDecode(rrt,1);
cbd=lteCodeBlockDesegment(td,length(data)/2);
out=double(cbd);
end
