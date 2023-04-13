function out = filename_encode(filename)
%% ���ļ������б���
len_filename = length(filename);
bits_tail = de2bi(len_filename,8);
file_ascii = [];
 for i = 1:length(filename)
    ascii = unicode2native(filename(i));           % ��ȡ�ַ���ASCII��
    if length(ascii) == 1
        file_ascii = [file_ascii 0];
        file_ascii = [file_ascii ascii];
    else
        file_ascii = [file_ascii ascii];
    end
 end

bits = dec2bin(file_ascii,8);    % ��������ASCII��ֵת��Ϊ�����Ʊ��룬�õ���Ϊ�ַ���������Ϊ8�ľ���
bits = bits';               %ת��
bits = reshape(bits,[],1)' ;

out = [];
for i = 1:length(bits)
    if bits(i) == '0'
        out = [out,0];
    else
        out = [out,1];
    end
end
out = [out,bits_tail];
end