function out = de_QAM(data,M)
%%
if M==4
    len=length(data);
    out(1:2:2*len)=real(data);
    out(2:2:2*len)=imag(data);
elseif M == 16
    len=length(data);
    bit0=real(data);
    bit2=imag(data);
    bit1=2/sqrt(10)-abs(real(data));
    bit3=2/sqrt(10)-abs(imag(data));
    out(1:4:4*len)=bit0;
    out(2:4:4*len)=bit1;
    out(3:4:4*len)=bit2;
    out(4:4:4*len)=bit3;
end
end