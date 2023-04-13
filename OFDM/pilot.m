function out = pilot(QAM_data,N_fft,N_c,N_zero)
%% 空载波位置
zero_position1 = (N_fft-N_zero+3)/2:1:(N_fft+N_zero-1)/2;
zero_position = [1 zero_position1];
%% 导频位置
P_f=1+1*1i;                                                     %Pilot
P_f_inter = ceil((N_fft-N_zero-1)/(N_fft-N_c)) ;                %导频间隔
P_f_position1=1:P_f_inter:(N_fft-N_zero+1)/2;
P_f_position1(1) = 2;                                           %1为空载波
P_f_position2=(N_fft+N_zero+1)/2:P_f_inter:N_fft;
P_f_position = [P_f_position1 P_f_position2];
P_f_position = P_f_position(1:N_fft-N_c);
%% 数据位置
data_position = setdiff(1:N_fft,union(P_f_position,zero_position)); 
%% 填充OFDM信号
data_row=length(data_position);
data_col=ceil(length(QAM_data)/data_row);
pilot_num = length(P_f_position);
pilot_seq=ones(pilot_num,data_col)*P_f;  %导频的位置
data=zeros(N_fft,data_col);              %预设整个矩阵
data(P_f_position(1:end),:)=pilot_seq;     %对pilot_seq按行取
if data_row*data_col>length(QAM_data)
    %将数据矩阵补齐，补0是虚载频~
    QAM_data=[QAM_data;zeros(data_row*data_col-length(QAM_data),1)];
end
%% 串并转换
data_seq=reshape(QAM_data,data_row,data_col);
data(data_position(1:end),:)=data_seq;%将导频与数据合并
out = data;
end