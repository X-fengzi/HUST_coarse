function out = equalization(data,N_fft,N_c,N_zero)
%% ���ز�λ��
zero_position1 = (N_fft-N_zero+3)/2:1:(N_fft+N_zero-1)/2;
zero_position = [1 zero_position1];
%% ��Ƶλ��
P_f=1+1*1i;                       %Pilot
P_f_inter = ceil((N_fft-N_zero-1)/(N_fft-N_c)) ;                 %��Ƶ���
P_f_position1=1:P_f_inter:(N_fft-N_zero+1)/2;
P_f_position1(1) = 2;
P_f_position2=(N_fft+N_zero+1)/2:P_f_inter:N_fft;
P_f_position = [P_f_position1 P_f_position2];
P_f_position = P_f_position(1:N_fft-N_c);
pilot_num = length(P_f_position);
%% ����λ��
data_position = setdiff(1:N_fft,union(P_f_position,zero_position));               %����λ��
%% 
data=data(1:N_fft,:); 
size_data = size(data);
pilot_seq = ones(pilot_num,size_data(2))*P_f;
Rx_pilot=data(P_f_position(1:end),:);                       %���յ��ĵ�Ƶ
h=Rx_pilot./pilot_seq; 
%�ֶ����Բ�ֵ����ֵ�㴦����ֵ�����������ڽ������������Ժ���Ԥ�⡣
%�Գ�����֪�㼯�Ĳ�ֵ����ָ����ֵ�������㺯��ֵ
H=interp1( P_f_position(1:end)',h,data_position(1:end)','linear','extrap');
%% �ŵ�У��
data_equ=data(data_position(1:end),:)./H;
data_equ = data_equ./sqrt(mean(abs(data_equ).^2));        %���ʹ�һ��
out = reshape(data_equ,[],1);
end
%%