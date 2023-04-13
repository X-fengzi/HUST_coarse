function out = QAM(data,M)
%% 对信号进行调制
if M==4
    %% 星座图 是 pi/4的 奇数倍
    table=exp(1i*[-3*pi/4 -pi/4 pi/4 3*pi/4]); 
    table=table([0 3 1 2]+1);     % 格雷编码
    
    data_in=reshape(data,2,length(data)/2);
    out=table([2 1]*data_in+1); 
    
elseif M==16
    %% 星座图：正方形调制
    m=1;
    table=zeros(1,16);
    for n=-3:2:3
        for k=-3:2:3
            table(m)=n+1i*k; m=m+1;
        end
    end
    table=table([0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10]+1)./sqrt(10);  %格雷编码,归一化
    
    data_in=reshape(data,4,length(data)/4);
    out=table([8 4 2 1]*data_in+1);   
else
    error(' ')
end
end