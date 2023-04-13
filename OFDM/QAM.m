function out = QAM(data,M)
%% ���źŽ��е���
if M==4
    %% ����ͼ �� pi/4�� ������
    table=exp(1i*[-3*pi/4 -pi/4 pi/4 3*pi/4]); 
    table=table([0 3 1 2]+1);     % ���ױ���
    
    data_in=reshape(data,2,length(data)/2);
    out=table([2 1]*data_in+1); 
    
elseif M==16
    %% ����ͼ�������ε���
    m=1;
    table=zeros(1,16);
    for n=-3:2:3
        for k=-3:2:3
            table(m)=n+1i*k; m=m+1;
        end
    end
    table=table([0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10]+1)./sqrt(10);  %���ױ���,��һ��
    
    data_in=reshape(data,4,length(data)/4);
    out=table([8 4 2 1]*data_in+1);   
else
    error(' ')
end
end