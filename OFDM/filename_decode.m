function [info_bits,filename] = filename_decode(R_bits)
%% ���ݽ��ձ��ؽ����ļ���
len_bits = R_bits(end-8+1:end);
len = bi2de(len_bits);
filename_bits = R_bits(end-8-len*16+1:end-8);
info_bits = R_bits(1:end-8-len*16);

str_bit='';
for i = 1:length(filename_bits)
    if filename_bits(i) == 0
        str_bit = strcat(str_bit,'0');
    else
        str_bit = strcat(str_bit,'1');
    end
end
number = floor(length(str_bit)/16); 
filename ='';   % ��ʼ��������Ϣ
for i = 0:number-1
        temp1 = str_bit(1 + 16 * i:8 + 16 * i);   % ÿ8λ���ؽ��б��ص��ַ���ת��
        temp2 = str_bit(9 + 16 * i:(i + 1) * 16);
        if temp1 == '00000000'
            string = native2unicode(bin2dec(temp2)) ;  % ������ת��Ϊ�ַ���            
        else
            string = native2unicode([bin2dec(temp1) bin2dec(temp2)]) ;  % ������ת��Ϊ�ַ���
        end
        filename = strcat(filename,string);   % ����

end
end