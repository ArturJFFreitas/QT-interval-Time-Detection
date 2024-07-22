% clc
% clear
close all

T = 10; 
l = length(val); 
t = linspace(0, T, l); 
canal = {'I', 'II', 'III', 'AVR', 'AVL', 'AVF' , 'V1', 'V2', 'V3', 'V4', 'V5', 'V6'};

% Signal display
figure
for i = 1:12
    subplot(6, 2, i)
    plot(t, val(i,:)), xlabel('Tempo (s)'), ylabel('Intesidade'), title([canal(i)])
end

[QT, QTc] = intervalo_QT(val)

function [QT_med, QTc] = intervalo_QT(val)
% Pre-processing
val = val(2,:);
l = length(val);
T = 10;
t = linspace(0, T, l);
% figure
% plot(t, val), title('Sinal original'), xlabel('Tempo (s)'), ylabel('Amplitude')

% Signal filtration
% High frequency noise removal
N = 9; 
num = 1/N*ones(1, N); 
den = 1; 

f1 = filter(num, den, val); 

% figure
% plot(t, f1)
% hold on
% plot(t, val), title('Eliminação do ruído de alta frequência'), xlabel('Tempo (s)'), ylabel('Amplitude'), legend('Filtrado', 'Não filtrado')

% Low frequency noise removal
num = [1 -1]; 
den = [1 -0.995]; 

f2 = filter(num, den, f1); 

% figure
% subplot(2, 1, 1)
% plot(t, f1), title('Eliminação do ruído de baixa intensidade'), xlabel('Tempo (s)'), ylabel('Amplitude'), legend('Após 1 filtragem')
% subplot(2, 1, 2)
% plot(t, f2), xlabel('Tempo (s)'), ylabel('Amplitude'), legend('Após 2 filtragens')
% Corrigir o primeiro pico

% Electrical grid interference removal
num = [1 -0.618 1]; 
den = 1; 

f3 = filter(num, den, f2); 

% figure
% plot(t, f2)
% hold on
% plot(t, f3), title('Eliminação da interferência da rede elétrica'), xlabel('Tempo (s)'), ylabel('Amplitude'), legend('Após 2 filtragens', 'Após 3 filtragens')

% Processing
ECG = f3; % Mudança de nome da variável para ser mais instintivo

% Signal normalization
ECG_min = min(f3);
ECG = ECG-ECG_min;

ECG_max = max(ECG);
ECG = ECG./ECG_max;

figure() 
plot(t, ECG), title('Normalização do sinal'), xlabel('Tempo (s)'), ylabel('Amplitude')

% RR-peaks detection
int = find(ECG >= 0.56 & ECG <= 0.64);

erro = [];
j = 1;

for i = 1:length(int)-2
    if int(i+1)-int(i) < 200
        if int(i+2)-int(i+1) < 200
            erro(j) = int(i+1);
            j = j+1;
        end
    end
end

% Variable cleaning
j = 1;
for i = 1:length(int)-1
    if int(i) == erro(j)
        int(i) = NaN;
        j = j+1;
    end
end    
int = int(~isnan(int));

% R-peak time finding
for i = 1:length(int)/2
    j = i*2-1;
    R_val(i) = max(ECG(int(j):int(j+1)));
    R_t(i) = find(ECG == R_val(i));
end

R_t(1) = []; R_t(end) = [];

% RR-interval
for i = 1:length(R_t)-1
    RR(i) = (R_t(i+1)-R_t(i))/1000; 
end

% S-peak detection
% t_S = 100 ms = 100 samples
for i = 1:length(R_t)
    if R_t(i)+100 > length(t) 
        S_val(i) = min(ECG(R_t(i):end));
        S_t(i) = find(ECG == S_val(i));
    else
        S_val(i) = min(ECG(R_t(i):R_t(i)+100));
        S_t(i) = find(ECG == S_val(i));
    end
end

% T-peak detection
% t_T = 300 ms = 300 samples
for i = 1:length(S_t)
    if S_t(i)+300 > length(t)
        T_val(i) = max(ECG(S_t(i):end)); 
        T_t(i) = find(ECG == T_val(i));
    else
        T_val(i) = max(ECG(S_t(i):S_t(i)+300));
        T_t(i) = find(ECG == T_val(i));
    end
end

% End of QT-segment detection
% t_QT_fim = 280 ms = 280 samples
for i = 1:length(T_t)
    if T_t(i)+280 > length(t)
        QT_fim_val(i) = min(ECG(T_t(i):end)); 
        QT_fim_t(i) = find(ECG == QT_fim_val(i));
    else
        QT_fim_val(i) = min(ECG(T_t(i):T_t(i)+280));
        QT_fim_t(i) = find(ECG == QT_fim_val(i));
    end
end

% Beggining of QT-segment detection
% t_QT_fim = 140 ms = 140 samples
for i = 1:length(R_t)
    if R_t(i)-140 < 0
        Q_val(i) = min(ECG(1:R_t(i))); 

        Q_t(i) = find(ECG == Q_val(i));
    else
        Q_val(i) = min(ECG(R_t(i)-140):R_t(i));
        Q_t(i) = find(ECG == Q_val(i));
    end
end

% QT-interval
for i = 1:length(Q_t)
    QT(i) = (QT_fim_t(i)-Q_t(i))/1000; 
end

% First and last beat removal
QT(1) = []; QT(end) = [];

% Final result (in seconds)
QT_med = mean(QT);

RR_med = mean(RR);
QTc = QT_med/sqrt(RR_med);
end
