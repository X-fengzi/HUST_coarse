function out = Encoder(filename)
%%  ��Դ����
fid = fopen(filename,'r');    %���ļ�
data = fread(fid);            %��ȡ�ļ��Ķ����ƴ洢����(��ȡ������Ϊʮ����)
fclose(fid);

bits = de2bi(data);           %����ȡ������ת��Ϊ������
tx_bs = reshape(bits,[],1)';  %����ת��Ϊ������
out = tx_bs;
end