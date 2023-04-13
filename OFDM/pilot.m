function out = pilot(QAM_data,N_fft,N_c,N_zero)
%% ���ز�λ��
zero_position1 = (N_fft-N_zero+3)/2:1:(N_fft+N_zero-1)/2;
zero_position = [1 zero_position1];
%% ��Ƶλ��
P_f=1+1*1i;                                                     %Pilot
P_f_inter = ceil((N_fft-N_zero-1)/(N_fft-N_c)) ;                %��Ƶ���
P_f_position1=1:P_f_inter:(N_fft-N_zero+1)/2;
P_f_position1(1) = 2;                                           %1Ϊ���ز�
P_f_position2=(N_fft+N_zero+1)/2:P_f_inter:N_fft;
P_f_position = [P_f_position1 P_f_position2];
P_f_position = P_f_position(1:N_fft-N_c);
%% ����λ��
data_position = setdiff(1:N_fft,union(P_f_position,zero_position)); 
%% ���OFDM�ź�
data_row=length(data_position);
data_col=ceil(length(QAM_data)/data_row);
pilot_num = length(P_f_position);
pilot_seq=ones(pilot_num,data_col)*P_f;  %��Ƶ��λ��
data=zeros(N_fft,data_col);              %Ԥ����������
data(P_f_position(1:end),:)=pilot_seq;     %��pilot_seq����ȡ
if data_row*data_col>length(QAM_data)
    %�����ݾ����룬��0������Ƶ~
    QAM_data=[QAM_data;zeros(data_row*data_col-length(QAM_data),1)];
end
%% ����ת��
data_seq=reshape(QAM_data,data_row,data_col);
data(data_position(1:end),:)=data_seq;%����Ƶ�����ݺϲ�
out = data;
end