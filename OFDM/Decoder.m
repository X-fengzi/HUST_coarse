function  Decoder(bitstream,filename)
%% ��Դ����
str_bit = reshape(bitstream,[],8);   %�����任
data = bi2de(str_bit);               %�������Ʊ���ת��Ϊʮ��������

fid = fopen(filename,'w+');          %��һ�����ļ�
fwrite(fid,data);                    %������д���ļ�
fclose(fid);
end
